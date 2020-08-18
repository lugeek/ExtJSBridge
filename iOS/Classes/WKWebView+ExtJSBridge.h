//
//  WKWebView+ExtJSBridge.h
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/13.
//

#import <WebKit/WebKit.h>
#import "ExtJSBridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (ExtJSBridge)

@property (nonatomic, strong, readonly) NSArray<ExtJSBridge *> *ext_bridges;

- (void)ext_connectToBridge:(ExtJSBridge *)bridge;

- (void)ext_disonnectBridge:(ExtJSBridge *)bridge;

@end

NS_ASSUME_NONNULL_END
