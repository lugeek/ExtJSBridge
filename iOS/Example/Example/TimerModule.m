//
//  TimerModule.m
//  Example
//
//  Created by hang_pan on 2020/9/8.
//  Copyright © 2020 pn-x. All rights reserved.
//

#import "TimerModule.h"


#define TIMER_KEY @"timer"
#define CALLBACK_KEY @"callback"

@interface TimerHandler : NSObject

@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) id target;

@end

@implementation TimerHandler

- (void)handleTimer:(NSTimer *)timer {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_target performSelector:_selector withObject:timer];
    #pragma clang diagnostic pop
}

@end

@interface TimerModule()

@property (nonatomic, strong) NSMutableDictionary *timerDic;

@end

@implementation TimerModule

- (instancetype)initWithBridge:(ExtJSBridge *)bridge {
    self = [super initWithBridge:bridge];
    if (self) {
        _timerDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)setTimeout:(id)arg callback:(ExtJSCallback)callback {
    NSInteger second = [arg[@"millseconds"] integerValue] / 1000;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        callback(ExtJSCallbackFunctionSuccess, nil);
    });
    return nil;
}

- (id)setInterval:(id)arg callback:(ExtJSCallback)callback {
    NSInteger second = [arg[@"millseconds"] integerValue] / 1000;
    TimerHandler *handler = [TimerHandler new];
    handler.target = self;
    handler.selector = @selector(handleTimer:);
    NSTimer *timer = [NSTimer timerWithTimeInterval:second target:handler selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    NSNumber *key = @([timer hash]);
    _timerDic[key] = @{TIMER_KEY:timer, CALLBACK_KEY:callback};
    [timer fire];
    return key;
}

- (id)clearInterval:(id)arg {
    if (![arg isKindOfClass:[NSNumber class]] || _timerDic[arg] == nil) {
        return nil;
    }
    NSTimer *timer = _timerDic[arg][TIMER_KEY];
    [timer invalidate];
    timer = nil;
    _timerDic[arg] = nil;
    return nil;
}

- (void)handleTimer:(NSTimer *)timer {
    NSNumber *key = @([timer hash]);
    ExtJSCallback callback = _timerDic[key][CALLBACK_KEY];
    callback(ExtJSCallbackFunctionProgress, nil);
}

- (void)dealloc {
    for (NSString *key in _timerDic) {
        NSTimer *timer = _timerDic[key][TIMER_KEY];
        [timer invalidate];
        timer = nil;
    }
}

+ (NSDictionary *)exportMethods {
    return @{
        @"setTimeout":@NO,
        @"setInterval":@NO,
        @"clearInterval":@YES,
    };
}

+ (NSString *)moduleName {
    return @"timer";
}
@end
