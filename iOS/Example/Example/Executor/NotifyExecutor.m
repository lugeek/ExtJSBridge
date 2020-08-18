//
//  NotifyExecutor.m
//  Example
//
//  Created by hang_pan on 2020/8/17.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "NotifyExecutor.h"
#import <ExtJSBridge/ExtJSBridgeHeader.h>

@implementation NotifyExecutor

+ (instancetype)singleton {
    static NotifyExecutor *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [NotifyExecutor new];
    });
    return obj;
}

- (void)ext_handleJSMessage:(ExtJSMessage *)message {
    if ([message.action isEqualToString:@"post"] && message.kind == ExtJSMessageKindNormal) {
        NSString *name = message.value[@"name"];
        NSNumber *value = message.value[@"value"];
        if (name) {
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:value];
        }
    }
}
@end
