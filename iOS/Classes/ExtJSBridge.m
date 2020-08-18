//
//  ExtJSBridge.m
//  Pods-Example
//
//  Created by hang_pan on 2020/8/12.
//

#import "ExtJSBridge.h"

@interface ExtJSBridge() {
    dispatch_queue_t _searialQueue;
    dispatch_queue_t _searialCallbackQueue;
}

@end

@implementation ExtJSBridge

- (instancetype)init {
    return [self initWithName:@"ext"];
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        NSAssert(name.length > 0, @"[ExtJSBridge]Invalid bridge message");
        _name = name;
        _searialQueue = dispatch_queue_create([NSString stringWithFormat:@"com.ExtJSBridge.queue-%@", self].UTF8String, DISPATCH_QUEUE_SERIAL);
        _searialCallbackQueue = dispatch_queue_create([NSString stringWithFormat:@"com.ExtJSBridge.callbackQueue-%@", self].UTF8String, DISPATCH_QUEUE_SERIAL);
        self.security = [ExtJSSecurity new];
        self.builder = [ExtJSExecutorBuilder new];
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSAssert([message.name isEqualToString:self.name], @"[ExtJSBridge]Invalid message name");
    NSAssert([message.body isKindOfClass:[NSString class]], @"[ExtJSBridge]Invalid message body");
    if (![message.name isEqualToString:self.name] || ![message.body isKindOfClass:[NSString class]]) {
        return;
    }
    id messageBody = message.body;
    WKFrameInfo *frameInfo = message.frameInfo;
    WKWebView *webView = message.webView;
    NSString *URLString = webView.URL.absoluteString;
    dispatch_async(_searialQueue, ^{
        NSDictionary *body = [ExtJSMessage parseRawString:messageBody];
        NSString *target = body[ExtJSArgumentTarget];
        NSString *action = body[ExtJSArgumentAction];
        NSString *valueType = body[ExtJSArgumentValueType];
        id value = body[ExtJSArgumentValue];
        NSString *mID = body[ExtJSArgumentID];
        NSString *timestamp = body[ExtJSArgumentTimestamp];
        NSString *compactURLString = [ExtJSMessage URLStringWithoutQueryAndFragment:URLString];
        ExtJSMessageKind kind = [body[ExtJSArgumentKind] integerValue];
        if (kind > 2 || kind < 0) {
            kind = ExtJSMessageKindNormal;
        }
        NSAssert(mID.length > 0, @"[ExtJSBridge]Invalid mID");
        NSAssert(timestamp.length > 0, @"[ExtJSBridge]Invalid timestamp");
        NSAssert(target.length > 0, @"[ExtJSBridge]Invalid target");
        NSAssert(action.length > 0, @"[ExtJSBridge]Invalid action");
        if (mID.length < 0 || timestamp.length < 0 || target.length < 0 || action.length < 0) {
            return;
        }
        ExtJSMessage *jsMessage = [[ExtJSMessage alloc] initWithTarget:target action:action mID:mID timestamp:timestamp kind:kind valueType:valueType value:value frameInfo:frameInfo compactURLString:compactURLString webView:webView bridgeName:self.name queue:self->_searialCallbackQueue];
        __weak typeof(self) weakSelf = self;
        [self.security verifyMessage:jsMessage complete:^(BOOL passed) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!passed) {
                return;
            }
            id<ExtJSExecutorProtocol> executor = [strongSelf.builder buildExecutorWithMessage:jsMessage];
            if (!executor) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [executor ext_handleJSMessage:jsMessage];
            });
        }];
    });
}

@end
