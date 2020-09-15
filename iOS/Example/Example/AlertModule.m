//
//  AlertModule.m
//  Example
//
//  Created by hang_pan on 2020/9/8.
//  Copyright © 2020 pn-x. All rights reserved.
//

#import "AlertModule.h"

@implementation AlertModule

- (UIWindow *)rootWindow {
    NSArray *windows = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                windows = windowScene.windows;
                break;
            }
        }
    } else {
        windows = [UIApplication sharedApplication].windows;
    }
    UIWindow *window = windows.firstObject;
    return window;
}

EXT_JS_SYNC_METHOD(show) {
    if (![arg isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:arg[@"title"] message:arg[@"message"] preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self.rootWindow.rootViewController presentViewController:controller animated:YES completion:nil];
    return nil;
}

+ (NSDictionary *)exportMethods {
    return @{
        @"show":@YES,
    };
}

+ (NSString *)moduleName {
    return @"alert";
}
@end
