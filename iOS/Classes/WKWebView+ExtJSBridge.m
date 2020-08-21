//
//  WKWebView+ExtJSBridge.m
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/13.
//

#import "WKWebView+ExtJSBridge.h"
#import <objc/runtime.h>

@implementation WKWebView (ExtJSBridge)

+ (void)load {
    [self ext_swizzlingMethod:@selector(setUIDelegate:) withMethod:@selector(hookedSetUIDelegate:)];
    [self ext_swizzlingMethod:@selector(UIDelegate) withMethod:@selector(hookedUIDelegate)];
}

+ (BOOL)ext_swizzlingMethod:(SEL)ori withMethod:(SEL)dest {
    Method origMethod = class_getInstanceMethod(self, ori);
    if (!origMethod) {
        return NO;
    }
    Method destMethod = class_getInstanceMethod(self, dest);
    if (!destMethod) {
        return NO;
    }
    class_addMethod(self,ori,class_getMethodImplementation(self, ori),method_getTypeEncoding(origMethod));
    class_addMethod(self,dest,class_getMethodImplementation(self, dest),method_getTypeEncoding(destMethod));
    method_exchangeImplementations(class_getInstanceMethod(self, ori), class_getInstanceMethod(self, dest));
    return YES;
}

- (ExtJSBridge *)ext_bridge {
    return objc_getAssociatedObject(self, "ext_bridge");
}

- (void)ext_setBridge:(ExtJSBridge *)bridge {
    objc_setAssociatedObject(self, "ext_bridge", bridge, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)hookedSetUIDelegate:(id<WKUIDelegate>)UIDelegate {
    if (UIDelegate == (id<WKUIDelegate>)self.ext_bridge) {
        @throw [NSException exceptionWithName:@"Bridge cannot be UIDelegate" reason:@"" userInfo:nil];
    }
    if (self.ext_bridge != nil) {
        [self.ext_bridge setValue:UIDelegate forKeyPath:@"_realUIDelegate"];
        return;
    }
    [self hookedSetUIDelegate:UIDelegate];
}

- (id<WKUIDelegate>)hookedUIDelegate {
    if (self.ext_bridge) {
        return [self.ext_bridge valueForKeyPath:@"_realUIDelegate"];
    }
    return [self hookedUIDelegate];
}

//default name ext
- (void)ext_initializeBridge {
    [self ext_initializeBridgeWithName:@"ext"];
}

- (void)ext_initializeBridgeWithName:(NSString *)name {
    if (self.ext_bridge) {
        return;
    }
    ExtJSBridge *bridge = [[ExtJSBridge alloc] initWithName:name webView:self];
    id delegate = self.UIDelegate;
    [self hookedSetUIDelegate:(id<WKUIDelegate>)bridge];
    [self ext_setBridge:bridge];
    if (delegate) {
        [self.ext_bridge setValue:delegate forKeyPath:@"_realUIDelegate"];
    }
    [self.configuration.userContentController addScriptMessageHandler:bridge name:bridge.name];
}

@end
