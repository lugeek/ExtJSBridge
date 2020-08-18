//
//  ExtJSMessage.m
//  ExtJS
//
//  Created by Pn-X on 2020/8/15.
//

#import "ExtJSMessage.h"
#import <CommonCrypto/CommonDigest.h>


NSString * const ExtJSArgumentID = @"id";
NSString * const ExtJSArgumentTimestamp = @"timestamp";
NSString * const ExtJSArgumentTarget = @"target";
NSString * const ExtJSArgumentAction = @"action";
NSString * const ExtJSArgumentValue = @"value";
NSString * const ExtJSArgumentValueType = @"valueType";
NSString * const ExtJSArgumentKind = @"kind";

NSString * const ExtJSValueTypeString = @"S";
NSString * const ExtJSValueTypeNumber = @"N";
NSString * const ExtJSValueTypeBool = @"B";
NSString * const ExtJSValueTypeObject = @"O";
NSString * const ExtJSValueTypeArray = @"A";
NSString * const ExtJSValueTypeError = @"E";

@interface ExtJSMessage()

@property (nonatomic, assign) NSUInteger sequence;
@property (nonatomic, strong) dispatch_queue_t callbackQueue;
@property (nonatomic, assign) BOOL hasInvoked;
@property (nonatomic, strong) NSString *deallocJS;

@end

@implementation ExtJSMessage

- (instancetype)initWithTarget:(NSString *)target action:(NSString *)action mID:(NSString *)mID timestamp:(NSString *)timestamp kind:(ExtJSMessageKind)kind valueType:(NSString *)valueType value:(id)value frameInfo:(WKFrameInfo *)frameInfo compactURLString:(NSString *)compactURLString webView:(WKWebView *)webView bridgeName:(NSString *)bridgeName queue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        _hasInvoked = NO;
        _sequence = 0;
        _target = target;
        _action = action;
        _mID = mID;
        _timestamp = timestamp;
        _kind = kind;
        _valueType = valueType;
        _value = value;
        _frameInfo = frameInfo;
        _webView = webView;
        _bridgeName = bridgeName;
        _callbackQueue = queue;
        _compactURLString = compactURLString;
        _uniqueMessageKey = [ExtJSMessage MD5FromString:[NSString stringWithFormat:@"%@-%@-%@-%@", target, action, mID, compactURLString]];
        _uniqueSubscribeKey = [ExtJSMessage MD5FromString:[NSString stringWithFormat:@"%@-%@-%@-%@", target, action, @"", compactURLString]];
        _deallocJS = [self generateCallbackWithFunction:@"_d" valueType:@"S" value:@""];
    }
    return self;
}

- (void)dealloc {
    WKWebView *webView = self.webView;
    NSString *js = self.deallocJS;
    if (!webView) {
        return;
    }
    if ([NSThread currentThread].isMainThread) {
        if ((_kind == ExtJSMessageKindNormal && _hasInvoked) || _kind == ExtJSMessageKindUnsubscribe) {
            return;
        }
        if (![self compareWithCurrentURL:webView.URL]) {
            return;
        }
        [webView evaluateJavaScript:js completionHandler:nil];
    } else {
        __block NSURL *URL = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            URL = webView.URL;
        });
        if (![self compareWithCurrentURL:URL]) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [webView evaluateJavaScript:js completionHandler:nil];
        });
    }
}

#pragma mark - public
- (void)invokeCallbackWithParams:(id)params complete:(void(^)(BOOL success, ExtJSCallbackFailedReason reason))complete {
    dispatch_async(self.callbackQueue, ^{
        if (self.kind == ExtJSMessageKindUnsubscribe) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(NO, ExtJSCallbackFailedReasonUnsupported);
                }
            });
            return;
        }
        WKWebView *webView = self.webView;
        if (webView == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(NO, ExtJSCallbackFailedReasonWebViewDestroyed);
                }
            });
            return;
        }
        __block NSURL *URL = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            URL = webView.URL;
        });
        if (![self compareWithCurrentURL:URL]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(NO, ExtJSCallbackFailedReasonURLChanged);
                }
            });
            return;
        }
        id value = params;
        NSString *valueType = ExtJSValueTypeString;
        if ([params isKindOfClass:[NSString class]]) {
        } else if ([params isKindOfClass:[NSNumber class]]) {
            valueType = ExtJSValueTypeNumber;
        } else if ([params isKindOfClass:[NSError class]] || [params isKindOfClass:[NSException class]]) {
            valueType = ExtJSValueTypeError;
            NSString *errorName = @"";
            NSString *errorCode = @"0";
            if ([params isKindOfClass:[NSException class]]) {
                errorName = [(NSException *)params name];
            } else {
                errorName = [(NSError *)params domain];
            }
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"m":errorName,@"c":errorCode} options:0 error:nil];
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else if ([params isKindOfClass:[NSArray class]]) {
            valueType = ExtJSValueTypeArray;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
            if (!jsonData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) {
                        complete(NO, ExtJSCallbackFailedReasonParamInvalid);
                    }
                });
                return;
            }
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else if ([params isKindOfClass:[NSSet class]]) {
            valueType = ExtJSValueTypeArray;
            NSArray *array = [(NSSet *)params allObjects];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
            if (!jsonData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) {
                        complete(NO, ExtJSCallbackFailedReasonParamInvalid);
                    }
                });
                return;
            }
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else if ([params isKindOfClass:[NSDictionary class]]) {
            valueType =ExtJSValueTypeObject;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
            if (!jsonData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) {
                        complete(NO, ExtJSCallbackFailedReasonParamInvalid);
                    }
                });
                return;
            }
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        NSString *js = @"";
        if (self.kind == ExtJSMessageKindNormal) {
            if ([valueType isEqualToString:ExtJSValueTypeError]) {
                js = [self generateCallbackWithFunction:@"_f" valueType:valueType value:value];
            } else {
                js = [self generateCallbackWithFunction:@"_s" valueType:valueType value:value];
            }
        } else if (self.kind == ExtJSMessageKindSubscribe) {
            js = [self generateCallbackWithFunction:@"_o" valueType:valueType value:value];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.hasInvoked && self.kind == ExtJSMessageKindNormal) {
                if (complete) {
                    complete(NO, ExtJSCallbackFailedReasonHasInvoked);
                }
                return;
            }
            self.hasInvoked = YES;
            [webView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                if (complete) {
                    complete(YES, ExtJSCallbackFailedReasonUnkown);
                }
            }];
        });
    });
}

// target/action/messageId/timestamp/messageKind/valueType/value
+ (NSDictionary *)parseRawString:(NSString *)rawString {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *array = [rawString componentsSeparatedByString:@"/"];
    if (array.count > 0) {
        dic[ExtJSArgumentTarget] = array[0];
    }
    if (array.count > 1) {
        dic[ExtJSArgumentAction] = array[1];
    }
    if (array.count > 2) {
        dic[ExtJSArgumentID] = array[2];
    }
    if (array.count > 3) {
        dic[ExtJSArgumentTimestamp] = array[3];
    }
    if (array.count > 4) {
        dic[ExtJSArgumentKind] = array[4];
    }
    if (array.count > 5) {
        dic[ExtJSArgumentValueType] = array[5];
    }
    if (array.count > 6) {
        id obj = [self valueFromString:array[6] valueType:dic[ExtJSArgumentValueType]];
        if (obj) {
            dic[ExtJSArgumentValue] = obj;
        }
    }
    return dic;
}

+ (NSString *)URLStringWithoutQueryAndFragment:(NSString *)URLString {
    NSString *string = URLString;
    if ([string containsString:@"?"]) {
        string = [string componentsSeparatedByString:@"?"].firstObject;
    } else if ([string containsString:@"#"]) {
        string = [string componentsSeparatedByString:@"#"].firstObject;
    }
    return string;
}

#pragma mark - private
// target/action/messageId/timestamp/messageKind/valueType/value
- (NSString *)generateCallbackWithFunction:(NSString *)function valueType:(NSString *)valueType value:(NSString *)value {
    return [NSString stringWithFormat:@"%@.%@('%@/%@/%@/%@/%ld/%@/%@')", self.bridgeName, function, self.target, self.action, self.mID, self.timestamp, self.kind, valueType, value];
}

- (BOOL)compareWithCurrentURL:(NSURL *)URL {
    NSString *oldURLString = [ExtJSMessage URLStringWithoutQueryAndFragment:self.frameInfo.request.URL.absoluteString];
    NSString *newURLString = [ExtJSMessage URLStringWithoutQueryAndFragment:URL.absoluteString];
    if ([oldURLString isEqualToString:newURLString]) {
        return YES;
    }
    return NO;
}

+ (NSString *)MD5FromString:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)string.length, digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    return result;
}

+ (id)valueFromString:(NSString *)string valueType:(NSString *)valueType {
    if ([valueType isEqualToString:ExtJSValueTypeError]) {
        NSData *jsonData = [string.stringByRemovingPercentEncoding dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            return [NSError errorWithDomain:@"ExtJSBridge" code:-1 userInfo:nil];
        }
        return [NSError errorWithDomain:@"ExtJSBridge" code:-1 userInfo:nil];
    }
    if ([valueType isEqualToString:ExtJSValueTypeArray]) {
        NSData *jsonData = [string.stringByRemovingPercentEncoding dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        if (![array isKindOfClass:[NSArray class]]) {
            return nil;
        }
        return array;
    }
    if ([valueType isEqualToString:ExtJSValueTypeObject]) {
        NSData *jsonData = [string.stringByRemovingPercentEncoding dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        return dic;
    }
    if ([valueType isEqualToString:ExtJSValueTypeBool] || [valueType isEqualToString:ExtJSValueTypeNumber]) {
        if ([string.stringByRemovingPercentEncoding containsString:@"."]) {
            return @([string doubleValue]);
        }
        return @([string integerValue]);
    }
    if ([valueType isEqualToString:ExtJSValueTypeString]) {
        return [string stringByRemovingPercentEncoding];
    }
    return nil;
}

@end
