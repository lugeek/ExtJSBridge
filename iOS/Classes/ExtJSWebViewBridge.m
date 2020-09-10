//
//  ExtJSWebViewBridge.m
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import "ExtJSWebViewBridge.h"
#import "ExtJSModuleFactory.h"
#import "ExtJSModule.h"
#import "ExtJSToolBox.h"
#import "ExtJSSession.h"
#import "ExtJSCleaner.h"


#define URL_KEYPATH @"URL"

@interface ExtJSWebViewBridge()<WKUIDelegate>

@property (nonatomic, weak) id<WKUIDelegate> realUIDelegate;
@property (nonatomic, strong) NSMutableDictionary *moduleInstanceCache;

@end

@implementation ExtJSWebViewBridge

- (instancetype)init {
    @throw [NSException exceptionWithName:@"InvalidInitializeMethod" reason:@"must use -initWithName:context:" userInfo:nil];
}

- (instancetype)initWithName:(NSString *)name webView:(WKWebView *)webView {
    self = [super initWithName:name];
    if (self) {
        _webView = webView;
        [_webView addObserver:self forKeyPath:URL_KEYPATH options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
        _moduleInstanceCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (nullable ExtJSModule *)moduleInstanceWithName:(NSString *)moduleName {
    return _moduleInstanceCache[moduleName];
}

- (void)removeModuleInstanceWithName:(NSString *)moduleName {
    _moduleInstanceCache[moduleName] = nil;
}

- (UIViewController *)currentController {
    UIResponder *responder = self.webView;
    while (responder.nextResponder) {
       responder = responder.nextResponder;
       if ([responder isKindOfClass:[UIViewController class]]) {
           break;
       }
    }
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                responder = windowScene.windows.firstObject.rootViewController;
                break;
            }
        }
    } else {
        responder = [UIApplication sharedApplication].delegate.window.rootViewController;
    }
    return (UIViewController *)responder;
}

- (void)dealloc {
    [_webView removeObserver:self forKeyPath:URL_KEYPATH];
}
#pragma mark - Bin
- (void)handleBinSession:(ExtJSSession *)session webView:(WKWebView *)webView handler:(void (^)(NSString * _Nullable result))handler {
    if ([session.action isEqualToString:@"installModule"]) {
        NSArray *array = session.value;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *name in array) {
            NSString *JSModuleClass = [[ExtJSModuleFactory singleton] JSModuleClassWithName:name];
            if (JSModuleClass) {
                dic[name] = JSModuleClass;
            }
        }
        handler([ExtJSToolBox convertNativeValue:dic]);
        return;
    }
    if ([session.action isEqualToString:@"requireModule"]) {
        ExtJSModule *moduleInstance = _moduleInstanceCache[session.value];
        if (!moduleInstance) {
            Class moduleClass = [[ExtJSModuleFactory singleton] moduleClassWithName:session.value];
            if (moduleClass) {
                moduleInstance = [[moduleClass alloc] initWithBridge:self];
                _moduleInstanceCache[session.value] = moduleInstance;
            }
        }
        if (!moduleInstance) {
            handler([ExtJSToolBox convertNativeValue:@"0"]);
        } else {
            handler([ExtJSToolBox convertNativeValue:@"1"]);
        }
        return;
    }
    handler(@"");
}

#pragma mark - observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:URL_KEYPATH] && object == _webView) {
        NSURL *URL = change[NSKeyValueChangeNewKey];
        for (NSString *key in _moduleInstanceCache) {
            ExtJSModule *instance = _moduleInstanceCache[key];
            [instance handleURLChanged:URL];
        }
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if ([_realUIDelegate respondsToSelector:_cmd]) {
        return [_realUIDelegate webView:webView createWebViewWithConfiguration:configuration forNavigationAction:navigationAction windowFeatures:windowFeatures];
    }
    return nil;
}

- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0)) {
    if ([_realUIDelegate respondsToSelector:_cmd]) {
        [_realUIDelegate webViewDidClose:webView];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    if ([_realUIDelegate respondsToSelector:_cmd]) {
        [_realUIDelegate webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self.currentController presentViewController:controller animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    if ([_realUIDelegate respondsToSelector:_cmd]) {
        [_realUIDelegate webView:webView runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [self.currentController presentViewController:controller animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    if (![prompt isEqualToString:self.name]) {
        if ([_realUIDelegate respondsToSelector:_cmd]) {
            [_realUIDelegate webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
            return;
        }
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:UIAlertControllerStyleAlert];
        [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = defaultText;
        }];
        [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(@"");
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *text = controller.textFields[0].text;
            completionHandler(text?:@"");
        }]];
        [self.currentController presentViewController:controller animated:YES completion:nil];
        return;
    }
    ExtJSSession *session = [[ExtJSSession alloc] initWithCompactSession:defaultText];
    if (!session) {
        completionHandler(@"");
        return;
    }
    if ([session.target isEqual:@"bin"]) {
        [self handleBinSession:session webView:webView handler:completionHandler];
        return;
    }
    NSString *oldURLString = webView.URL.absoluteString;
    ExtJSModule *moduleInstance = _moduleInstanceCache[session.target];
    if (!moduleInstance) {
        Class moduleClass = [[ExtJSModuleFactory singleton] moduleClassWithName:session.value];
        if (moduleClass) {
            moduleInstance = [[moduleClass alloc] initWithBridge:self];
            _moduleInstanceCache[session.value] = moduleInstance;
        }
    }
    if (!moduleInstance) {
        completionHandler([ExtJSToolBox convertNativeValue:@(0)]);
        return;
    }
    NSDictionary *dic = [[ExtJSModuleFactory singleton] moduleMethodsWithName:session.target];
    NSNumber *isSync = dic[session.action];
    if (isSync == nil) {
        completionHandler([ExtJSToolBox convertNativeValue:@(0)]);
        return;
    }
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([isSync boolValue]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:", session.action]);
        id ret = [moduleInstance performSelector:selector withObject:session.value];
        NSString *JSValue = [ExtJSToolBox convertNativeValue:ret];
        completionHandler(JSValue);
        return;
    }
    NSString *name = self.name;
    __weak WKWebView *weakWebView = webView;
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:callback:", session.action]);
    ExtJSCompactSession *cleanCompactSesstion = [ExtJSToolBox createCompactSessionWithTarget:session.target action:session.action sID:session.sID compactValue:@"N/0"];
    ExtJSRunnableJS *cleanJS = [ExtJSToolBox createRunnableJSWithBridgeName:name function:ExtJSCallbackFunctionFail compactSession:cleanCompactSesstion];
    ExtJSCleaner *cleaner = [[ExtJSCleaner alloc] initWithDeallocBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakWebView evaluateJavaScript:cleanJS completionHandler:nil];
        });
    }];
    ExtJSCallback callback = ^(ExtJSCallbackFunction *function, _Nullable id result) {
        ExtJSCompactValue *compactValue = [ExtJSToolBox convertNativeValue:result];
        ExtJSCompactSession *compactSesstion = [ExtJSToolBox createCompactSessionWithTarget:session.target action:session.action sID:session.sID compactValue:compactValue];
        ExtJSRunnableJS *callbackJS = [ExtJSToolBox createRunnableJSWithBridgeName:name function:function compactSession:compactSesstion];
        if ([NSThread currentThread].isMainThread) {
            if (![ExtJSToolBox compareURLString:oldURLString withAnotherURLString:weakWebView.URL.absoluteString]) {
                return;
            }
            [weakWebView evaluateJavaScript:callbackJS completionHandler:nil];
            cleaner.cancel = YES;
        } else {
            __block NSURL *URL = nil;
            dispatch_sync(dispatch_get_main_queue(), ^{
                URL = weakWebView.URL;
            });
            if (![ExtJSToolBox compareURLString:oldURLString withAnotherURLString:URL.absoluteString]) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakWebView evaluateJavaScript:callbackJS completionHandler:nil];
                cleaner.cancel = YES;
            });
        }
    };
    id ret = [moduleInstance performSelector:selector withObject:session.value withObject:callback];
    NSString *JSValue = [ExtJSToolBox convertNativeValue:ret];
    completionHandler(JSValue);
    #pragma clang diagnostic pop
}

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_DEPRECATED_WITH_REPLACEMENT("webView:contextMenuConfigurationForElement:completionHandler:", ios(10.0, 13.0)) {
    if ([_realUIDelegate respondsToSelector:_cmd]) {
        return [_realUIDelegate webView:webView shouldPreviewElement:elementInfo];
    }
    return YES;
}

- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions API_DEPRECATED_WITH_REPLACEMENT("webView:contextMenuConfigurationForElement:completionHandler:", ios(10.0, 13.0)) {
    if ([_realUIDelegate respondsToSelector:_cmd]) {
        return [_realUIDelegate webView:webView previewingViewControllerForElement:elementInfo defaultActions:previewActions];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController API_DEPRECATED_WITH_REPLACEMENT("webView:contextMenuForElement:willCommitWithAnimator:", ios(10.0, 13.0)) {
    if ([_realUIDelegate respondsToSelector:_cmd]) {
        [_realUIDelegate webView:webView commitPreviewingViewController:previewingViewController];
    }
}

- (void)webView:(WKWebView *)webView contextMenuConfigurationForElement:(WKContextMenuElementInfo *)elementInfo completionHandler:(void (^)(UIContextMenuConfiguration * _Nullable configuration))completionHandler API_AVAILABLE(ios(13.0)) {
    if ([_realUIDelegate respondsToSelector:_cmd]) {
        [_realUIDelegate webView:webView contextMenuConfigurationForElement:elementInfo completionHandler:completionHandler];
        return;
    }
    completionHandler(nil);
}

- (void)webView:(WKWebView *)webView contextMenuWillPresentForElement:(WKContextMenuElementInfo *)elementInfo API_AVAILABLE(ios(13.0)) {
    if ([_realUIDelegate respondsToSelector:_cmd]) {
        [_realUIDelegate webView:webView contextMenuWillPresentForElement:elementInfo];
    }
}

- (void)webView:(WKWebView *)webView contextMenuForElement:(WKContextMenuElementInfo *)elementInfo willCommitWithAnimator:(id <UIContextMenuInteractionCommitAnimating>)animator API_AVAILABLE(ios(13.0)) {
    if ([_realUIDelegate respondsToSelector:_cmd]) {
        [_realUIDelegate webView:webView contextMenuForElement:elementInfo willCommitWithAnimator:animator];
    }
}

- (void)webView:(WKWebView *)webView contextMenuDidEndForElement:(WKContextMenuElementInfo *)elementInfo API_AVAILABLE(ios(13.0)) {
    if ([_realUIDelegate respondsToSelector:_cmd]) {
        [_realUIDelegate webView:webView contextMenuDidEndForElement:elementInfo];
    }
}

@end
