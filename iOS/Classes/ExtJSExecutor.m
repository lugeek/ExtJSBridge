//
//  ExtJSExecutor.m
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/21.
//

#import "ExtJSExecutor.h"
#import "ExtJSBridge.h"

@interface ExtJSExecutor()

@property (nonatomic, strong)NSMutableDictionary *subscribeMessageMap;

@end

@implementation ExtJSExecutor

- (instancetype)initWithBridge:(ExtJSBridge *)bridge {
    self = [super init];
    if (self) {
        self.subscribeMessageMap = [NSMutableDictionary dictionary];
        _bridge = bridge;
    }
    return self;
}

- (void)didChangeValue:(id)value withAction:(NSString *)action {
    [self.bridge didChangeValue:value withTargets:[[self class] executorNames] action:action];
}

- (BOOL)verifyMessage:(ExtJSMessage *)message {
    return YES;
}

- (id)handleSyncMessage:(ExtJSNormalMessage *)message {
    return nil;
}

- (void)handleAsyncMessage:(ExtJSNormalMessage *)message callback:(ExtJSCallbackStatus(^)(__nullable id result))callback {
    callback(nil);
}

+ (NSArray <NSString *> *)executorNames {
    return @[NSStringFromClass([self class])];
}

@end
