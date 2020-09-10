//
//  JSContext+ExtJSBridge.m
//  AFNetworking
//
//  Created by hang_pan on 2020/8/20.
//

#import "JSContext+ExtJSBridge.h"
#import <objc/runtime.h>

@implementation JSContext (ExtJSBridge)

- (ExtJSContextBridge *)ext_bridge {
    return objc_getAssociatedObject(self, "ext_bridge");
}

- (void)ext_setBridge:(ExtJSContextBridge *)bridge {
    objc_setAssociatedObject(self, "ext_bridge", bridge, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)ext_initializeBridge {
    [self ext_initializeBridgeWithName:@"ext"];
}

- (void)ext_initializeBridgeWithName:(NSString *)name {
    @synchronized (self) {
        if (self.ext_bridge != nil) {
            return;
        }
        ExtJSContextBridge *bridge = [[ExtJSContextBridge alloc] initWithName:name context:self];
        [self ext_setBridge:bridge];
        NSString *name = [NSString stringWithFormat:@"native_%@", bridge.name];
        self[name] = bridge;
    }
}

@end
