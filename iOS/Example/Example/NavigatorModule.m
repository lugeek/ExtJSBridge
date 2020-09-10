//
//  NavigatorModule.m
//  Example
//
//  Created by hang_pan on 2020/9/8.
//  Copyright © 2020 pn-x. All rights reserved.
//

#import "NavigatorModule.h"
#import <ExtJSBridge/ExtJSWebViewBridge.h>

@implementation NavigatorModule

- (void)handleViewDidAppear {
    [self postMessage:@"onPageAppear" object:nil];
}

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

- (id)close:(id)arg {
    [(UINavigationController *)self.rootWindow.rootViewController popViewControllerAnimated:YES];
    return nil;
}

- (id)open:(id)arg {
    if (![arg isKindOfClass:[NSString class]]) {
        return nil;
    }
    Class cls = NSClassFromString(@"ViewController");
    if ([arg isEqualToString:@"webview"]) {
        cls = NSClassFromString(@"WebViewController");
    } else if ([arg isEqualToString:@"jscore"]) {
        cls = NSClassFromString(@"JSCoreViewController");
    }
    [(UINavigationController *)self.rootWindow.rootViewController pushViewController:[cls new] animated:YES];
    return nil;
}

- (id)setTitle:(id)arg {
    if (![arg isKindOfClass:[NSString class]]) {
        return nil;
    }
    self.rootWindow.rootViewController.title = arg;
    return nil;
}

+ (NSArray *)exportMessages {
    return @[
        @"onPageAppear",
    ];
}

+ (NSDictionary *)exportMethods {
    return @{
        @"open":@YES,
        @"close":@YES,
        @"setTitle":@YES,
    };
}

+ (NSString *)moduleName {
    return @"navigator";
}

@end
