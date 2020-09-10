//
//  ExtJSWebViewBridge.h
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import "ExtJSBridge.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExtJSWebViewBridge : ExtJSBridge

@property (nonatomic, weak, nullable, readonly) WKWebView *webView;

- (instancetype)initWithName:(NSString *)name webView:(WKWebView *)webView;

@end

NS_ASSUME_NONNULL_END
