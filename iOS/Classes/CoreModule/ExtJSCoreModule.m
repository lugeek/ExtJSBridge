//
//  ExtJSCoreModule.m
//  ExtJSBridge
//
//  Created by Pn-X on 2020/9/12.
//

#import "ExtJSCoreModule.h"
#import <objc/runtime.h>

NSString * const ExtJSMethodImplementSurfix = @"JSMethodImplement";

@implementation ExtJSCoreModule

- (instancetype)initWithBridge:(ExtJSBridge *)bridge {
    self = [super initWithBridge:bridge];
    if (self) {
        if ([bridge isKindOfClass:[ExtJSWebViewBridge class]]) {
            _globalObject = @"window";
        } else {
            _globalObject = @"globalThis";
        }
    }
    return self;
}

@end
