//
//  WKWebView+ExtJSBridge.h
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/13.
//

#import <WebKit/WebKit.h>
#import "ExtJSBridgeHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (ExtJSBridge)

@property (nonatomic, strong, readonly) ExtJSWebBridge *ext_bridge;
//default name ext
- (void)ext_initializeBridge;

- (void)ext_initializeBridgeWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
