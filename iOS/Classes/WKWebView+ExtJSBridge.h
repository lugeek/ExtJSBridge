//
//  WKWebView+ExtJSBridge.h
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/13.
//

#import <WebKit/WebKit.h>
#import "ExtJSWebViewBridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (ExtJSBridge)

@property (nonatomic, strong, readonly) ExtJSWebViewBridge *ext_bridge;

- (void)ext_initializeBridge;

@end

NS_ASSUME_NONNULL_END
