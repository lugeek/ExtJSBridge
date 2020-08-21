//
//  ExtJSBridge.m
//  Pods-Example
//
//  Created by hang_pan on 2020/8/12.
//

#import "ExtJSBridge.h"
#import "ExtJSExecutor.h"

@protocol ExtJSExport <JSExport>

JSExportAs(invoke, - (id)invoke:(NSString *)params);

@end

@interface ExtJSCleanUpTask : NSObject
    
@property (nonatomic, assign) BOOL cancel;
@property (nonatomic, copy) dispatch_block_t block;

@end

@implementation ExtJSCleanUpTask

- (instancetype)initWithDeallocBlock:(dispatch_block_t)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

- (void)start {
}

- (void)dealloc {
    if (!_cancel && _block) {
        _block();
    }
}
@end

static NSMutableDictionary *ExtJSGlobalExecutorMap;


@interface ExtJSBridge() <WKUIDelegate> {
    dispatch_queue_t _searialQueue;
}

@property (nonatomic, strong) NSMutableDictionary *executorCache;
@property (nonatomic, weak) id<WKUIDelegate> realUIDelegate;

@end

@implementation ExtJSBridge

+ (void)load {
    ExtJSGlobalExecutorMap = [NSMutableDictionary dictionary];
}

- (void)dealloc {
    if (_webView) {
        [_webView removeObserver:self forKeyPath:@"URL"];
    }
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
}

- (instancetype)initWithName:(NSString *)name webView:(WKWebView *)webView {
    NSAssert(name.length > 0, @"[ExtJSBridge]Invalid bridge message");
    NSAssert(webView != nil, @"[ExtJSBridge]Invalid webView");
    self = [super init];
    if (self) {
        _name = name;
        _searialQueue = dispatch_queue_create([NSString stringWithFormat:@"com.ExtJSBridge.queue-%@", self].UTF8String, DISPATCH_QUEUE_SERIAL);
        self.security = [ExtJSSecurity new];
        self.executorCache = [NSMutableDictionary dictionary];
        _webView = webView;
        [_webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name context:(JSContext *)context {
    NSAssert(name.length > 0, @"[ExtJSBridge]Invalid bridge message");
    NSAssert(context != nil, @"[ExtJSBridge]Invalid context");
    self = [super init];
    if (self) {
        _name = name;
        _searialQueue = dispatch_queue_create([NSString stringWithFormat:@"com.ExtJSBridge.queue-%@", self].UTF8String, DISPATCH_QUEUE_SERIAL);
        self.executorCache = [NSMutableDictionary dictionary];
        self.security = [ExtJSSecurity new];
    }
    return self;
}

+ (void)registExecutorClass:(Class)aClass {
    NSAssert(aClass != nil, @"[ExtJSExecutorBuilder][Class cannot be nil]");
    NSArray *names = [aClass executorNames];
    for (NSString *name in names) {
        if (ExtJSGlobalExecutorMap[name]) {
            @throw [NSException exceptionWithName:@"[ExtJSExecutorBuilder]Regist class failed"
                                           reason:[NSString stringWithFormat:@"%@ has been used by %@", name, ExtJSGlobalExecutorMap[name]]
                                         userInfo:@{}];
        }
        ExtJSGlobalExecutorMap[name] = aClass;
    }
}

- (void)didChangeValue:(id)value withTargets:(NSArray <NSString *> *)targets action:(NSString *)action {
    WKWebView *webView = self.webView;
    if (!webView) {
        return;
    }
    dispatch_async(self->_searialQueue, ^{
        NSString *valueStr = [ExtJSTool valueWithResult:value];
        NSString *valueType = [ExtJSTool valueTypeWithResult:value];
        NSString *js = [ExtJSTool createSubscribeCallbackJSWithBridgeName:self.name targets:targets action:action valueType:valueType value:valueStr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [webView evaluateJavaScript:js completionHandler:nil];
        });
    });
}

#pragma mark - private
- (ExtJSExecutor *)buildExecutorWithMessage:(ExtJSMessage *)message {
    if (self.executorCache[message.compactURLString][message.target] != nil) {
        return self.executorCache[message.compactURLString][message.target];
    }
    Class aClass = ExtJSGlobalExecutorMap[message.target];
    if (!aClass) {
        return nil;
    }
    ExtJSExecutor *executor = [[aClass alloc] initWithBridge:self];
    if (self.executorCache[message.compactURLString] == nil) {
        self.executorCache[message.compactURLString] = [NSMutableDictionary dictionary];
    }
    self.executorCache[message.compactURLString][message.target] = executor;
    return executor;
}

- (void)cleanUpExecutorCache {
    NSMutableDictionary *cache = self.executorCache;
    self.executorCache = [NSMutableDictionary dictionary];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [cache removeAllObjects];
    });
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSAssert([message.name isEqualToString:self.name], @"[ExtJSBridge]Invalid message name");
    NSAssert([message.body isKindOfClass:[NSString class]], @"[ExtJSBridge]Invalid message body");
    if (![message.name isEqualToString:self.name] || ![message.body isKindOfClass:[NSString class]]) {
        return;
    }
    id messageBody = message.body;
    WKFrameInfo *frame = message.frameInfo;
    WKWebView *webView = message.webView;
    NSString *URLString = webView.URL.absoluteString;
    dispatch_async(_searialQueue, ^{
        NSDictionary *body = [ExtJSTool parseJSONString:messageBody];
        NSString *target = body[ExtJSArgumentTarget];
        NSString *action = body[ExtJSArgumentAction];
        NSString *valueType = body[ExtJSArgumentValueType];
        id value = body[ExtJSArgumentValue];
        NSString *mID = body[ExtJSArgumentID];
        NSString *timestamp = body[ExtJSArgumentTimestamp];
        NSString *compactURLString = [ExtJSTool removeQueryAndFragmentWithURLString:URLString];
        NSInteger kind = [body[ExtJSArgumentKind] integerValue];
        if (kind != 1) {
            return;
        }
        NSAssert(mID.length > 0, @"[ExtJSBridge]Invalid mID");
        NSAssert(timestamp.length > 0, @"[ExtJSBridge]Invalid timestamp");
        NSAssert(target.length > 0, @"[ExtJSBridge]Invalid target");
        NSAssert(action.length > 0, @"[ExtJSBridge]Invalid action");
        if (mID.length < 0 || timestamp.length < 0 || target.length < 0 || action.length < 0) {
            return;
        }
        ExtJSNormalMessage *jsMessage = [[ExtJSNormalMessage alloc] initWithTarget:target action:action mID:mID timestamp:timestamp valueType:valueType value:value isSync:NO frameInfo:frame compactURLString:compactURLString bridge:self];
        NSString *cleanUpJS = [ExtJSTool createCleanUpCallbackJSWithMessage:jsMessage];
        BOOL passed = [self.security verifyMessage:jsMessage];
        if (!passed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [webView evaluateJavaScript:cleanUpJS completionHandler:^(id _Nullable object, NSError * _Nullable error) {}];
            });
            return;
        }
        ExtJSExecutor *executor = [self buildExecutorWithMessage:jsMessage];
        if (!executor || ![executor verifyMessage:jsMessage]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [webView evaluateJavaScript:cleanUpJS completionHandler:^(id _Nullable object, NSError * _Nullable error) {}];
            });
            return;
        }
        ExtJSCleanUpTask *task = [[ExtJSCleanUpTask alloc] initWithDeallocBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [webView evaluateJavaScript:cleanUpJS completionHandler:^(id _Nullable object, NSError * _Nullable error) {}];
            });
        }];
        [executor handleAsyncMessage:jsMessage callback:^ExtJSCallbackStatus(id result) {
            NSString *js = [ExtJSTool createCallbackJSWithResult:result message:jsMessage];
            if ([js isEqualToString:@""]) {
                return ExtJSCallbackStatusResultInvalid;
            }
            if ([NSThread currentThread].isMainThread) {
                if (![ExtJSTool compareURLString:URLString withAnotherURLString:webView.URL.absoluteString]) {
                    return ExtJSCallbackStatusURLChanged;
                }
                [webView evaluateJavaScript:js completionHandler:^(id _Nullable object, NSError * _Nullable error) {}];
                task.cancel = YES;
                return ExtJSCallbackStatusSucceed;
            } else {
                __block NSURL *URL = nil;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    URL = webView.URL;
                });
                if (![ExtJSTool compareURLString:URLString withAnotherURLString:URL.absoluteString]) {
                    return ExtJSCallbackStatusURLChanged;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [webView evaluateJavaScript:js completionHandler:^(id _Nullable object, NSError * _Nullable error) {}];
                    task.cancel = YES;
                });
                return ExtJSCallbackStatusSucceed;
            }
        }];
    });
}


//observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"URL"] && object == self.webView) {
        [self cleanUpExecutorCache];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


- (id)invoke:(NSString *)params {
    return nil;
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if ([self.realUIDelegate respondsToSelector:_cmd]) {
        return [self.realUIDelegate webView:webView createWebViewWithConfiguration:configuration forNavigationAction:navigationAction windowFeatures:windowFeatures];
    }
    return nil;
}

- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0)) {
    if ([self.realUIDelegate respondsToSelector:_cmd]) {
        [self.realUIDelegate webViewDidClose:webView];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    if ([self.realUIDelegate respondsToSelector:_cmd]) {
        [self.realUIDelegate webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    if ([self.realUIDelegate respondsToSelector:_cmd]) {
        [self.realUIDelegate webView:webView runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    completionHandler(NO);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    if ([prompt isEqualToString:self.name]) {
        NSString *URLString = webView.URL.absoluteString;
        NSDictionary *body = [ExtJSTool parseJSONString:defaultText];
        NSString *target = body[ExtJSArgumentTarget];
        NSString *action = body[ExtJSArgumentAction];
        NSString *valueType = body[ExtJSArgumentValueType];
        id value = body[ExtJSArgumentValue];
        NSString *mID = body[ExtJSArgumentID];
        NSString *timestamp = body[ExtJSArgumentTimestamp];
        NSString *compactURLString = [ExtJSTool removeQueryAndFragmentWithURLString:URLString];
        NSInteger kind = [body[ExtJSArgumentKind] integerValue];
        if (kind > 2 || kind < 0) {
            completionHandler(@"N/0");
            return;
        }
        NSAssert(mID.length > 0, @"[ExtJSBridge]Invalid mID");
        NSAssert(timestamp.length > 0, @"[ExtJSBridge]Invalid timestamp");
        NSAssert(target.length > 0, @"[ExtJSBridge]Invalid target");
        NSAssert(action.length > 0, @"[ExtJSBridge]Invalid action");
        if (mID.length < 0 || timestamp.length < 0 || target.length < 0 || action.length < 0) {
            completionHandler(@"N/0");
            return;
        }
        if (kind == 0 || kind == 1) {
            ExtJSNormalMessage *jsMessage = [[ExtJSNormalMessage alloc] initWithTarget:target action:action mID:mID timestamp:timestamp valueType:valueType value:value isSync:(kind == 0) frameInfo:frame compactURLString:compactURLString bridge:self];
            if (![self.security verifyMessage:jsMessage]) {
                completionHandler(@"N/0");
                return;
            }
            ExtJSExecutor *executor = [self buildExecutorWithMessage:jsMessage];
            if (!executor || ![executor verifyMessage:jsMessage]) {
                completionHandler(@"N/0");
                return;
            }
            id result = [executor handleSyncMessage:jsMessage];
            NSString *string = [ExtJSTool JSONFromResult:result];
            completionHandler(string);
            return;
        } else {
            ExtJSSubscribeMessage *jsMessage = [[ExtJSSubscribeMessage alloc] initWithTarget:target action:action mID:mID timestamp:timestamp frameInfo:frame compactURLString:compactURLString bridge:self];
            if (![self.security verifyMessage:jsMessage]) {
                completionHandler(@"N/0");
                return;
            }
            ExtJSExecutor *executor = [self buildExecutorWithMessage:jsMessage];
            if (!executor || ![executor verifyMessage:jsMessage]) {
                completionHandler(@"N/0");
                return;
            }
            completionHandler(@"N/1");
            return;
        }
    }
    if ([self.realUIDelegate respondsToSelector:_cmd]) {
        [self.realUIDelegate webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    completionHandler(@"");
}

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_DEPRECATED_WITH_REPLACEMENT("webView:contextMenuConfigurationForElement:completionHandler:", ios(10.0, 13.0)) {
    if ([self.realUIDelegate respondsToSelector:_cmd]) {
        return [self.realUIDelegate webView:webView shouldPreviewElement:elementInfo];
    }
    return YES;
}

- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions API_DEPRECATED_WITH_REPLACEMENT("webView:contextMenuConfigurationForElement:completionHandler:", ios(10.0, 13.0)) {
    if ([self.realUIDelegate respondsToSelector:_cmd]) {
        return [self.realUIDelegate webView:webView previewingViewControllerForElement:elementInfo defaultActions:previewActions];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController API_DEPRECATED_WITH_REPLACEMENT("webView:contextMenuForElement:willCommitWithAnimator:", ios(10.0, 13.0)) {
    if ([self.realUIDelegate respondsToSelector:_cmd]) {
        [self.realUIDelegate webView:webView commitPreviewingViewController:previewingViewController];
    }
}

- (void)webView:(WKWebView *)webView contextMenuConfigurationForElement:(WKContextMenuElementInfo *)elementInfo completionHandler:(void (^)(UIContextMenuConfiguration * _Nullable configuration))completionHandler API_AVAILABLE(ios(13.0)) {
    if ([self.realUIDelegate respondsToSelector:_cmd]) {
        [self.realUIDelegate webView:webView contextMenuConfigurationForElement:elementInfo completionHandler:completionHandler];
        return;
    }
    completionHandler(nil);
}

- (void)webView:(WKWebView *)webView contextMenuWillPresentForElement:(WKContextMenuElementInfo *)elementInfo API_AVAILABLE(ios(13.0)) {
    if ([self.realUIDelegate respondsToSelector:_cmd]) {
        [self.realUIDelegate webView:webView contextMenuWillPresentForElement:elementInfo];
    }
}

- (void)webView:(WKWebView *)webView contextMenuForElement:(WKContextMenuElementInfo *)elementInfo willCommitWithAnimator:(id <UIContextMenuInteractionCommitAnimating>)animator API_AVAILABLE(ios(13.0)) {
    if ([self.realUIDelegate respondsToSelector:_cmd]) {
        [self.realUIDelegate webView:webView contextMenuForElement:elementInfo willCommitWithAnimator:animator];
    }
}

- (void)webView:(WKWebView *)webView contextMenuDidEndForElement:(WKContextMenuElementInfo *)elementInfo API_AVAILABLE(ios(13.0)) {
    if ([self.realUIDelegate respondsToSelector:_cmd]) {
        [self.realUIDelegate webView:webView contextMenuDidEndForElement:elementInfo];
    }
}

@end
