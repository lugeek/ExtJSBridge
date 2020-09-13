//
//  ExtJSContextBridge.m
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import "ExtJSContextBridge.h"
#import "ExtJSModuleFactory.h"
#import "ExtJSModule.h"
#import "ExtJSToolBox.h"
#import "ExtJSCleaner.h"

@protocol ExtJSContextExport <JSExport>

JSExportAs(invoke, - (id)invokeTarget:(NSString *)target action:(NSString *)action sID:(NSString *)sID valueType:(NSString *)valueType value:(id)value);

- (NSString *)platform;

@end

@interface ExtJSContextBridge()<ExtJSContextExport>

@end

@implementation ExtJSContextBridge

- (instancetype)init {
    @throw [NSException exceptionWithName:@"InvalidInitializeMethod" reason:@"must use -initWithName:context:" userInfo:nil];
}

- (instancetype)initWithName:(NSString *)name context:(JSContext *)context {
    NSAssert(name.length > 0, @"[ExtJSBridge]Invalid bridge message");
    NSAssert(context != nil, @"[ExtJSBridge]Invalid context");
    self = [super initWithName:name];
    if (self) {
        _context = context;
    }
    return self;
}

#pragma mark - ExtJSCoreExport
- (NSString *)platform {
    return @"iOS";
}

- (id)invokeTarget:(NSString *)target action:(NSString *)action sID:(NSString *)sID valueType:(NSString *)valueType value:(id)value {
    if ([self.name isEqualToString:target] ) {
        if ([@"loadCore" isEqualToString:action]) {
            id ret = [self loadCore];
            return [ExtJSToolBox compactValue:ret];
        }
        return ExtJSCompactValueFalse;
    }
    ExtJSModule *moduleInstance = self.moduleInstanceCache[target];
    if (!moduleInstance) {
        return ExtJSCompactValueFalse;
    }
    NSDictionary *dic = [[ExtJSModuleFactory singleton] moduleInfoWithName:target].methodMap;
    NSNumber *isSync = dic[action];
    if (isSync == nil) {
        return ExtJSCompactValueFalse;
    }
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([isSync boolValue]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:", action]);
        id ret = [moduleInstance performSelector:selector withObject:[ExtJSToolBox convertStringValue:value valueType:valueType]];
        return [ExtJSToolBox compactValue:ret];
    }
    __weak JSContext *context = _context;
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:callback:", action]);
    ExtJSCompactSession *compactSesstion = [ExtJSToolBox compactSessionWithTarget:target action:action sID:sID valueType:ExtJSValueTypeBool value:@"0"];
    ExtJSRunnableJS *cleanJS = [ExtJSToolBox createWithFunction:ExtJSCallbackFunctionFail compactSession:compactSesstion];
    ExtJSCleaner *cleaner = [[ExtJSCleaner alloc] initWithDeallocBlock:^{
        [context evaluateScript:cleanJS];
    }];
    ExtJSCallback callback = ^(ExtJSCallbackFunction *function, _Nullable id result) {
        ExtJSValueType *valueType = [ExtJSToolBox getValueType:result];
        NSString *value = [ExtJSToolBox convertValue:result];
        ExtJSCompactSession *compactSesstion = [ExtJSToolBox compactSessionWithTarget:target action:action sID:sID valueType:valueType value:value];
        ExtJSRunnableJS *callbackJS = [ExtJSToolBox createWithFunction:function compactSession:compactSesstion];
        [context evaluateScript:callbackJS];
        cleaner.cancel = YES;
    };
    id ret = [moduleInstance performSelector:selector withObject:[ExtJSToolBox convertStringValue:value valueType:valueType] withObject:callback];
    return [ExtJSToolBox compactValue:ret];
    #pragma clang diagnostic pop
}

@end
