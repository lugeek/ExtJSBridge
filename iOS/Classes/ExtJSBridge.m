//
//  ExtJSBridge.m
//  Pods-Example
//
//  Created by hang_pan on 2020/8/12.
//

#import "ExtJSBridge.h"
#import "ExtJSExecutor.h"

static NSMutableDictionary *ExtJSGlobalExecutorMap;

@interface ExtJSBridge() 

@property (nonatomic, strong) NSMutableDictionary *executorCache;
@property (nonatomic, strong, readwrite) dispatch_queue_t queue;

@end

@implementation ExtJSBridge

+ (void)load {
    ExtJSGlobalExecutorMap = [NSMutableDictionary dictionary];
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

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        _executorCache = [NSMutableDictionary dictionary];
        _security = [ExtJSSecurity new];
        _queue = dispatch_queue_create([NSString stringWithFormat:@"com.ExtJSBridge.queue-%@", self].UTF8String, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)didChangeValue:(id)value withTargets:(NSArray <NSString *> *)targets action:(NSString *)action {
    @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
}

- (nullable ExtJSExecutor *)buildExecutorWithMessage:(ExtJSMessage *)message {
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
@end
