//
//  ExtJSTool.m
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/20.
//

#import "ExtJSTool.h"
#import "ExtJSMessage.h"
#import "ExtJSBridge.h"

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

@implementation ExtJSTool

// target/action/messageId/timestamp/messageKind/valueType/value
+ (NSDictionary *)parseJSONString:(NSString *)rawString {
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

// target/action/messageId/timestamp/messageKind/valueType/value
+ (NSString *)createCallbackJSWithBridgeName:(NSString *)bridgeName function:(NSString *)function target:(NSString *)target action:(NSString *)action mID:(NSString *)mID timestamp:(NSString *)timestamp valueType:(NSString *)valueType value:(NSString *)value {
    return [NSString stringWithFormat:@"%@.%@('%@/%@/%@/%@/0/%@/%@')", bridgeName, function, target, action, mID, timestamp, valueType, value];
}

+ (NSString *)createCallbackJSWithResult:(id)result message:(ExtJSMessage *)message {
    id value = [self valueWithResult:result];
    NSString *valueType = [self valueTypeWithResult:result];
    NSString *bridgeName = message.bridge.name;
    NSString *js = @"";
    if ([valueType isEqualToString:ExtJSValueTypeError]) {
        js = [self createCallbackJSWithBridgeName:bridgeName function:@"_f" target:message.target action:message.action mID:message.mID timestamp:message.timestamp valueType:valueType value:value];
    } else {
        js = [self createCallbackJSWithBridgeName:bridgeName function:@"_s" target:message.target action:message.action mID:message.mID timestamp:message.timestamp valueType:valueType value:value];
    }
    return js;
}

+ (NSString *)createCleanUpCallbackJSWithMessage:(ExtJSNormalMessage *)message {
    NSString *bridgeName = message.bridge.name;
    return [self createCallbackJSWithBridgeName:bridgeName function:@"_d" target:message.target action:message.action mID:message.mID timestamp:message.timestamp valueType:@"S" value:@""];
}

+ (NSString *)JSONFromResult:(id)result {
    id value = [self valueWithResult:result];
    NSString *valueType = [self valueTypeWithResult:result];
    return [NSString stringWithFormat:@"%@/%@", valueType, value];
}

+ (NSString *)valueTypeWithResult:(id)result {
    NSString *valueType = ExtJSValueTypeString;
    if ([result isKindOfClass:[NSNumber class]]) {
        valueType = ExtJSValueTypeNumber;
    } else if ([result isKindOfClass:[NSError class]] || [result isKindOfClass:[NSException class]]) {
        valueType = ExtJSValueTypeError;
    } else if ([result isKindOfClass:[NSArray class]]) {
        valueType = ExtJSValueTypeArray;
    } else if ([result isKindOfClass:[NSSet class]]) {
        valueType = ExtJSValueTypeArray;
    } else if ([result isKindOfClass:[NSDictionary class]]) {
        valueType =ExtJSValueTypeObject;
    }
    return valueType;
}

+ (NSString *)valueWithResult:(id)result {
    id value = result;
    if ([result isKindOfClass:[NSNumber class]]) {
         value = [NSString stringWithFormat:@"%@", result];
    } else if ([result isKindOfClass:[NSError class]] || [result isKindOfClass:[NSException class]]) {
        NSString *errorName = @"";
        NSString *errorCode = @"0";
        if ([result isKindOfClass:[NSException class]]) {
            errorName = [(NSException *)result name];
        } else {
            errorName = [(NSError *)result domain];
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"m":errorName,@"c":errorCode} options:0 error:nil];
        value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else if ([result isKindOfClass:[NSArray class]]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
        if (jsonData) {
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    } else if ([result isKindOfClass:[NSSet class]]) {
        NSArray *array = [(NSSet *)result allObjects];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
        if (jsonData) {
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    } else if ([result isKindOfClass:[NSDictionary class]]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
        if (jsonData) {
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    return value;
}

+ (NSString *)removeQueryAndFragmentWithURLString:(NSString *)URLString {
    NSString *string = URLString;
    if ([string containsString:@"?"]) {
        string = [string componentsSeparatedByString:@"?"].firstObject;
    } else if ([string containsString:@"#"]) {
        string = [string componentsSeparatedByString:@"#"].firstObject;
    }
    return string;
}

+ (BOOL)compareURLString:(NSString *)URLString withAnotherURLString:(NSString *)anotherURLString {
    NSString *oldURLString = [self removeQueryAndFragmentWithURLString:URLString];
    NSString *newURLString = [self removeQueryAndFragmentWithURLString:anotherURLString];
    if ([oldURLString isEqualToString:newURLString]) {
        return YES;
    }
    return NO;
}

+ (NSString *)createSubscribeCallbackJSWithBridgeName:(NSString *)bridgeName targets:(NSArray<NSString *> *)targets action:(NSString *)action valueType:(NSString *)valueType value:(id)value {
    NSString *targetString = [self valueWithResult:targets];
    return [NSString stringWithFormat:@"%@._o('%@/%@/%@/%@')", bridgeName, targetString, action, valueType, value];
}

#pragma mark - private
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
