//
//  ExtJSModuleFactory.m
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import "ExtJSModuleFactory.h"
#import "ExtJSToolBox.h"
#import "ExtJSModule.h"

@interface ExtJSModuleInfo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *JSModuleClass;
@property (nonatomic, strong) Class cls;
@property (nonatomic, strong) NSDictionary *methodMap;
@property (nonatomic, strong) NSMutableSet *messageSet;

@end

@implementation ExtJSModuleInfo

@end

@interface ExtJSModuleFactory()

@property (nonatomic, strong) NSMutableDictionary *moduleInfoMap;
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
        _moduleInfoMap = [NSMutableDictionary dictionary];
        _lock = [[NSLock alloc] init];
    }
    return self;;
}

- (void)registerModuleClass:(Class)moduleClass {
    assert([moduleClass isSubclassOfClass:[ExtJSModule class]]);
    [_lock lock];
    
    NSString *moduleName = [moduleClass moduleName];
    NSString *JSModuleClass = [ExtJSToolBox createJSModuleClassFromModuleClass:moduleClass];
    NSMutableDictionary *methodMap = [NSMutableDictionary dictionaryWithDictionary:[moduleClass exportMethods]];
    NSMutableSet *messageSet = [NSMutableSet setWithArray:[moduleClass exportMessages]];
    
    ExtJSModuleInfo *info = [ExtJSModuleInfo new];
    info.cls = moduleClass;
    info.name = moduleName;
    info.methodMap = methodMap;
    info.messageSet = messageSet;
    info.JSModuleClass = JSModuleClass;
    
    _moduleInfoMap[moduleName] = info;
    [_lock unlock];
}

- (void)registerModuleClasses:(NSArray <Class> *)moduleClasses {
    [_lock lock];
    for (Class moduleClass in moduleClasses) {
        NSString *moduleName = [moduleClass moduleName];
        NSString *JSModuleClass = [ExtJSToolBox createJSModuleClassFromModuleClass:moduleClass];
        NSMutableDictionary *methodMap = [NSMutableDictionary dictionaryWithDictionary:[moduleClass exportMethods]];
        NSMutableSet *messageSet = [NSMutableSet setWithArray:[moduleClass exportMessages]];
        
        ExtJSModuleInfo *info = [ExtJSModuleInfo new];
        info.cls = moduleClass;
        info.name = moduleName;
        info.methodMap = methodMap;
        info.messageSet = messageSet;
        info.JSModuleClass = JSModuleClass;
        
        _moduleInfoMap[moduleName] = info;
    }
    [_lock unlock];
}

- (Class)moduleClassWithName:(NSString *)name {
    assert(name != nil);
    ExtJSModuleInfo *info = nil;
    [_lock lock];
    info = _moduleInfoMap[name];
    [_lock unlock];
    return info.cls;
}

- (NSSet *)moduleMessagesWithName:(NSString *)name {
    assert(name != nil);
    ExtJSModuleInfo *info = nil;
    [_lock lock];
    info = _moduleInfoMap[name];
    [_lock unlock];
    return info.messageSet;
}

- (NSDictionary *)moduleMethodsWithName:(NSString *)name {
    assert(name != nil);
    ExtJSModuleInfo *info = nil;
    [_lock lock];
    info = _moduleInfoMap[name];
    [_lock unlock];
    return info.methodMap;
}


- (NSString *)JSModuleClassWithName:(NSString *)name {
    assert(name != nil);
    ExtJSModuleInfo *info = nil;
    [_lock lock];
    info = _moduleInfoMap[name];
    [_lock unlock];
    return info.JSModuleClass;
}

@end
