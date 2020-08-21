//
//  ExtJSBridge.h
//  Pods-Example
//
//  Created by hang_pan on 2020/8/12.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "ExtJSSecurity.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExtJSBridge : NSObject<WKScriptMessageHandler, JSExport> 

//default ext
@property (nonatomic, strong, readonly) NSString *name;

//the connected webview
@property (nonatomic, weak, nullable, readonly) WKWebView *webView;

//the connected context
@property (nonatomic, weak, nullable, readonly) JSContext *context;

//verify the message form webview to protect data
@property (nonatomic, strong) ExtJSSecurity *security;

- (instancetype)initWithName:(NSString *)name webView:(WKWebView *)webView;

- (instancetype)initWithName:(NSString *)name context:(JSContext *)context;

+ (void)registExecutorClass:(Class)aClass;

- (void)didChangeValue:(id)value withTargets:(NSArray <NSString *> *)targets action:(NSString *)action;

@end

NS_ASSUME_NONNULL_END
