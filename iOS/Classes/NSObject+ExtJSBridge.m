//
//  NSObject+ExtJSBridge.m
//  AFNetworking
//
//  Created by hang_pan on 2020/8/20.
//

#import "NSObject+ExtJSBridge.h"
#import <objc/runtime.h>

@implementation NSObject (ExtJSBridge)

- (NSDictionary *)ext_JSSubscriberMap {
    NSMutableDictionary *dic = objc_getAssociatedObject(self, "ext_JSSubscriberMap");
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, "ext_JSSubscriberMap", dic, OBJC_ASSOCIATION_RETAIN);
    }
    return dic;
}

- (void)ext_setJSSubscriberMap:(NSDictionary *)JSSubscriberMap {
    objc_setAssociatedObject(self, "ext_JSSubscriberMap", JSSubscriberMap, OBJC_ASSOCIATION_RETAIN);
}

- (void)ext_subscribeWithJSMessage:(ExtJSMessage *)message {
    assert(message.kind == ExtJSMessageKindSubscribe);
    if (message.kind != ExtJSMessageKindSubscribe) {
        return;
    }
    NSMutableDictionary *dic = self.ext_JSSubscriberMap[message.action];
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
    }
    dic[message.uniqueSubscribeKey] = message;
    ((NSMutableDictionary *)self.ext_JSSubscriberMap)[message.action] = dic;
}

- (void)ext_unsubscribeWithJSMessage:(ExtJSMessage *)message {
    NSMutableDictionary *dic = self.ext_JSSubscriberMap[message.action];
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
    }
    dic[message.uniqueSubscribeKey] = nil;
}

- (void)ext_callBackToJSSubscriberWithAction:(NSString *)action params:(id)params {
    assert(action != nil);
    NSDictionary *dic = self.ext_JSSubscriberMap[action];
    for (NSString *key in dic) {
        ExtJSMessage *message = dic[key];
        [message callbackWithParams:params complete:^(BOOL success, ExtJSCallbackFailedReason reason) {
            if (success == false && (reason == ExtJSCallbackFailedReasonWebViewDestroyed || reason == ExtJSCallbackFailedReasonURLChanged)) {
                self.ext_JSSubscriberMap[action][message.uniqueSubscribeKey] = nil;
            }
        }];
    }
}

@end
