//
//  WKWebView+ExtJSBridge.m
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/13.
//

#import "WKWebView+ExtJSBridge.h"
#import <objc/runtime.h>

@implementation WKWebView (ExtJSBridge)
- (NSArray<ExtJSBridge *>*)ext_bridges {
    return self.ext_bridgeMap.allValues;
}

- (NSMutableDictionary *)ext_bridgeMap {
    NSMutableDictionary *map = objc_getAssociatedObject(self, "ext_bridgeMap");
    if (!map) {
        map = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, "ext_bridgeMap", map, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return map;
}

- (void)ext_connectToBridge:(ExtJSBridge *)bridge {
    ExtJSBridge *added = self.ext_bridgeMap[bridge.name];
    if (added == bridge) {
        return;
    }
    if ([added.name isEqualToString:bridge.name]) {
        [self.configuration.userContentController removeScriptMessageHandlerForName:added.name];
    }
    self.ext_bridgeMap[bridge.name] = bridge;
    [self.configuration.userContentController addScriptMessageHandler:bridge name:bridge.name];
}

- (void)ext_disonnectBridge:(ExtJSBridge *)bridge {
    ExtJSBridge *added = self.ext_bridgeMap[bridge.name];
    if (added != bridge) {
        return;
    }
    self.ext_bridgeMap[bridge.name] = nil;
    [self.configuration.userContentController removeScriptMessageHandlerForName:bridge.name];
}

@end
