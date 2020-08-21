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
            UIViewController *vc = [self currentController];
            [vc presentViewController:alertController animated:YES completion:nil];
        });
    }
}

- (UIViewController *)currentController {
    UIViewController *vc = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                vc = windowScene.windows.firstObject.rootViewController;
                break;
            }
        }
    } else {
        vc = [UIApplication sharedApplication].delegate.window.rootViewController;
    }
    return vc;
}

//override by subclass
+ (NSArray <NSString *> *)executorNames {
    return @[@"alert"];
}

@end
