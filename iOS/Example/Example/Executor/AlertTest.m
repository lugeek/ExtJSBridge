//
//  AlertTest.m
//  Example
//
//  Created by hang_pan on 2020/8/18.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "AlertTest.h"

@implementation AlertTest

- (void)ext_handleJSMessage:(ExtJSMessage *)message {
    if ([message.action isEqualToString:@"show"] && message.kind == ExtJSMessageKindNormal) {
        NSString *title = message.value[@"title"];
        NSString *msg = message.value[@"message"];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [message callbackWithParams:@(YES) complete:nil];
        }];
        [alertController addAction:cancel];
        UIResponder *responder = message.webView;
        while (responder.nextResponder) {
            responder = responder.nextResponder;
            if ([responder isKindOfClass:[UIViewController class]]) {
                break;
            }
        }
        if (responder) {
            [(UIViewController *)responder presentViewController:alertController animated:YES completion:nil];
        } else {
            [message callbackWithParams:@(NO) complete:nil];
        }
    }
}

@end
