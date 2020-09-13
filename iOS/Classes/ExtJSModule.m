//
//  ExtJSModule.m
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import "ExtJSModule.h"
#import "ExtJSContextBridge.h"
#import "ExtJSWebViewBridge.h"
#import "ExtJSToolBox.h"
#import "ExtJSModuleFactory.h"

@interface ExtJSModule()

@end

@implementation ExtJSModule

- (instancetype)init {
    @throw [NSException exceptionWithName:@"InvalidInitializeMethod" reason:@"must use -initWithBridge:" userInfo:nil];
}

- (instancetype)initWithBridge:(ExtJSBridge *)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
        _name = [[self class] moduleName];
    }
    return self;
}

- (void)postMessage:(NSString *)message object:(nullable id)object {
    NSSet *set = [[ExtJSModuleFactory singleton] moduleInfoWithName:self.name].messageSet;
    assert(message != nil && message.length > 0 && [set containsObject:message]);
    if (![set containsObject:message]) {
        return;
    }
    if ([_bridge isKindOfClass:[ExtJSWebViewBridge class]]) {
        WKWebView *webView = ((ExtJSWebViewBridge *)_bridge).webView;
        ExtJSCompactValue *compactValue = [ExtJSToolBox convertValue:object];
        [webView evaluateJavaScript:[ExtJSToolBox createWithTarget:self.name message:message compactValue:compactValue] completionHandler:nil];
    } else {
        JSContext *context = ((ExtJSContextBridge *)_bridge).context;
        NSString *compactValue = [ExtJSToolBox convertValue:object];
        [context evaluateScript:[ExtJSToolBox createWithTarget:self.name message:message compactValue:compactValue]];
    }
}

- (void)handleURLChanged:(NSURL *)URL {
    
}

+ (NSArray *)exportMessages {
    return @[];
}

+ (NSDictionary *)exportMethods {
    return @{};
}

+ (NSString *)moduleName {
    return NSStringFromClass([self class]);
}

+ (NSString *)moduleDescription {
    return @"";
}

@end
