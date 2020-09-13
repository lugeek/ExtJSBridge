//
//  ExtJSBridge.m
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import "ExtJSBridge.h"
#import "ExtJSModule.h"
#import "ExtJSModuleFactory.h"

#define BRIDGE_NAME @""

NSString * const ExtJSBridgeDefaultName = @"ext";

@implementation ExtJSBridge

- (instancetype)init {
    return [self  initWithName:ExtJSBridgeDefaultName];
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        _moduleInstanceCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)loadCore {
    NSDictionary *dic = [ExtJSModuleFactory singleton].allCoreModuleInfo;
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *name in dic) {
        ExtJSModuleInfo *info = dic[name];
        result[name] = info.JSModuleClass;
        ExtJSModule *moduleInstance = _moduleInstanceCache[name];
        if (!moduleInstance) {
            Class moduleClass = info.cls;
            if (moduleClass) {
                moduleInstance = [[moduleClass alloc] initWithBridge:self];
                ((NSMutableDictionary *)_moduleInstanceCache)[name] = moduleInstance;
            }
        }
    }
    return result;
}
@end
