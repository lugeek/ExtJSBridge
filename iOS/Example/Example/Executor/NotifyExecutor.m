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

//override by subclass
- (BOOL)verifyMessage:(ExtJSMessage *)message {
    return YES;
}

//override by subclass
- (nullable id)handleSyncMessage:(ExtJSNormalMessage *)message {
    if ([message.action isEqualToString:@"post"]) {
        NSString *name = message.value[@"name"];
        id value = message.value[@"value"];
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:value];
    }
    return nil;
}

//override by subclass
- (void)handleAsyncMessage:(ExtJSNormalMessage *)message callback:(ExtJSCallbackStatus(^)(__nullable id result))callback {
    
}

//override by subclass
+ (NSArray <NSString *> *)executorNames {
    return @[@"notify"];
}
@end
