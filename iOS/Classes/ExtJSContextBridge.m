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

@property (nonatomic, strong) NSMutableDictionary *moduleInstanceCache;

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
#pragma mark - Bin
- (id)handleBinAction:(NSString *)action sID:(NSString *)sID valueType:(NSString *)valueType value:(id)value context:(JSContext *)context {
    if ([action isEqualToString:@"installModule"]) {
        NSArray *array = value;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *name in array) {
            NSString *JSModuleClass = [[ExtJSModuleFactory singleton] JSModuleClassWithName:name];
            if (JSModuleClass) {
                dic[name] = JSModuleClass;
            }
        }
        return [ExtJSToolBox convertNativeValue:dic];
    }
    if ([action isEqualToString:@"requireModule"]) {
        ExtJSModule *moduleInstance = _moduleInstanceCache[value];
        if (!moduleInstance) {
            Class moduleClass = [[ExtJSModuleFactory singleton] moduleClassWithName:value];
            if (moduleClass) {
                moduleInstance = [[moduleClass alloc] initWithBridge:self];
                _moduleInstanceCache[value] = moduleInstance;
            }
        }
        if (!moduleInstance) {
            return [ExtJSToolBox convertNativeValue:@(0)];
        }
        return [ExtJSToolBox convertNativeValue:@(1)];
    }
    return [ExtJSToolBox convertNativeValue:@(0)];
}

#pragma mark - ExtJSCoreExport
- (NSString *)platform {
    return @"iOS";
}

// compactSession format: target/action/sID/valueType/value
- (id)invokeTarget:(NSString *)target action:(NSString *)action sID:(NSString *)sID valueType:(NSString *)valueType value:(id)value {
    if ([target isEqualToString:ExtJSModuleNameBin]) {
        return [self handleBinAction:action sID:sID valueType:valueType value:value context:self.context];
    }
    ExtJSModule *moduleInstance = _moduleInstanceCache[target];
    if (!moduleInstance) {
        Class moduleClass = [[ExtJSModuleFactory singleton] moduleClassWithName:value];
        if (moduleClass) {
            moduleInstance = [[moduleClass alloc] initWithBridge:self];
            _moduleInstanceCache[value] = moduleInstance;
        }
    }
    if (!moduleInstance) {
        return [ExtJSToolBox convertNativeValue:@(0)];
    }
    NSDictionary *dic = [[ExtJSModuleFactory singleton] moduleMethodsWithName:target];
    NSNumber *isSync = dic[action];
    if (isSync == nil) {
        return [ExtJSToolBox convertNativeValue:@(0)];
    }
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([isSync boolValue]) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:", action]);
        id ret = [moduleInstance performSelector:selector withObject:value];
        return [ExtJSToolBox convertNativeValue:ret];
    }
    __weak JSContext *context = _context;
    NSString *name = self.name;
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:callback:", action]);
    ExtJSCompactSession *msg = [ExtJSToolBox createCompactSessionWithTarget:target action:action sID:sID compactValue:@"N/0"];
    ExtJSRunnableJS *cleanJS = [ExtJSToolBox createRunnableJSWithBridgeName:name function:ExtJSCallbackFunctionFail compactSession:msg];
    ExtJSCleaner *cleaner = [[ExtJSCleaner alloc] initWithDeallocBlock:^{
        [context evaluateScript:cleanJS];
    }];
    ExtJSCallback callback = ^(ExtJSCallbackFunction *function, _Nullable id result) {
        ExtJSCompactValue *compactValue = [ExtJSToolBox convertNativeValue:result];
        ExtJSCompactSession *msg = [ExtJSToolBox createCompactSessionWithTarget:target action:action sID:sID compactValue:compactValue];
        ExtJSRunnableJS *callbackJS = [ExtJSToolBox createRunnableJSWithBridgeName:name function:function compactSession:msg];
        [context evaluateScript:callbackJS];
        cleaner.cancel = YES;
    };
    id ret = [moduleInstance performSelector:selector withObject:value withObject:callback];
    return [ExtJSToolBox convertNativeValue:ret];
    #pragma clang diagnostic pop
}

@end
