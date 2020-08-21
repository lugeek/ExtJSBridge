//
//  ExtJSWebBridge.h
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/21.
//

#import "ExtJSBridge.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExtJSWebBridge : ExtJSBridge<WKScriptMessageHandler>

//the connected webview
@property (nonatomic, weak, nullable, readonly) WKWebView *webView;

- (instancetype)initWithName:(NSString *)name webView:(WKWebView *)webView;

@end

NS_ASSUME_NONNULL_END
