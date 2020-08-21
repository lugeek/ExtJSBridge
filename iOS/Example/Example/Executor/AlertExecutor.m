//
//  AlertExecutor.m
//  Example
//
//  Created by hang_pan on 2020/8/21.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "AlertExecutor.h"

@implementation AlertExecutor

//override by subclass
- (BOOL)verifyMessage:(ExtJSMessage *)message {
    if ([message.action hasPrefix:@"sync"]) {
        return NO;
    }
    return YES;
}

//override by subclass
- (nullable id)handleSyncMessage:(ExtJSNormalMessage *)message {
    return nil;
}

//override by subclass
- (void)handleAsyncMessage:(ExtJSNormalMessage *)message callback:(ExtJSCallbackStatus(^)(__nullable id result))callback {
    if ([message.action isEqualToString:@"show"]) {
        NSString *title = message.value[@"title"];
        NSString *msg = message.value[@"message"];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                callback(@YES);
            }];
            [alertController addAction:okAction];
            UIResponder *responder = self.bridge.webView;
            while (responder.nextResponder) {
               responder = responder.nextResponder;
               if ([responder isKindOfClass:[UIViewController class]]) {
                   break;
               }
            }
            if (responder) {
               [(UIViewController *)responder presentViewController:alertController animated:YES completion:nil];
            } else {
               callback(@NO);
            }
        });
    }
}

//override by subclass
+ (NSArray <NSString *> *)executorNames {
    return @[@"alert"];
}

@end
