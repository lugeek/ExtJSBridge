//
//  ExtJSModuleFactory.m
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import "ExtJSModuleFactory.h"
#import "ExtJSToolBox.h"
#import "ExtJSModule.h"
#import "ExtJSCoreModule.h"

@interface ExtJSModuleInfo()

@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *JSModuleClass;
@property (nonatomic, strong, readwrite) Class cls;
@property (nonatomic, strong, readwrite) NSDictionary *methodMap;
@property (nonatomic, strong, readwrite) NSMutableSet *messageSet;
@property (nonatomic, assign, readwrite) BOOL isCoreModule;

@end

@implementation ExtJSModuleInfo

@end

@interface ExtJSModuleFactory()

@property (nonatomic, strong) NSMutableDictionary <NSString *, ExtJSModuleInfo *>*coreModuleInfoMap;
@property (nonatomic, strong) NSMutableDictionary <NSString *, ExtJSModuleInfo *>*moduleInfoMap;
@property (nonatomic, strong) NSLock *lock;

@end

@implementation ExtJSModuleFactory

+ (instancetype)singleton {
    static ExtJSModuleFactory *object = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [ExtJSModuleFactory new];
    });
    return object;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _coreModuleInfoMap = [NSMutableDictionary dictionary];
        _moduleInfoMap = [NSMutableDictionary dictionary];
        _lock = [[NSLock alloc] init];
    }
    return self;;
}

- (void)registerModuleClass:(Class)moduleClass {
    [self registerModuleClasses:@[moduleClass]];
}

- (void)registerModuleClasses:(NSArray <Class> *)moduleClasses {
    [_lock lock];
    for (Class moduleClass in moduleClasses) {
        assert([moduleClass isSubclassOfClass:[ExtJSModule class]]);
        
        NSString *moduleName = [moduleClass moduleName];
        
        assert(_moduleInfoMap[moduleName] == nil);
        
        NSString *JSModuleClass = [ExtJSToolBox createJSModuleClassFromModuleClass:moduleClass];
        NSMutableDictionary *methodMap = [NSMutableDictionary dictionaryWithDictionary:[moduleClass exportMethods]];
        NSMutableSet *messageSet = [NSMutableSet setWithArray:[moduleClass exportMessages]];
        
        ExtJSModuleInfo *info = [ExtJSModuleInfo new];
        info.cls = moduleClass;
        info.name = moduleName;
        info.methodMap = methodMap;
        info.messageSet = messageSet;
        info.JSModuleClass = JSModuleClass;
        info.isCoreModule = false;
        
        if ([moduleClass isSubclassOfClass:[ExtJSCoreModule class]]) {
            _coreModuleInfoMap[moduleName] = info;
            info.isCoreModule = true;
        }
        _moduleInfoMap[moduleName] = info;
    }
    [_lock unlock];
}

- (ExtJSModuleInfo *)moduleInfoWithName:(NSString *)name {
    assert(name != nil);
    ExtJSModuleInfo *info = nil;
    [_lock lock];
    info = _moduleInfoMap[name];
    [_lock unlock];
    return info;
}

- (NSDictionary <NSString *, ExtJSModuleInfo *> *)allCoreModuleInfo {
    NSDictionary *dic = nil;
    [_lock lock];
    dic = [_coreModuleInfoMap copy];
    [_lock unlock];
    return dic;
}
@end
