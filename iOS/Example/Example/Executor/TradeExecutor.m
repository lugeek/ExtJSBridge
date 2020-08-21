//
//  TradeExecutor.m
//  Example
//
//  Created by hang_pan on 2020/8/13.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "TradeExecutor.h"
#import "BaseTrade.h"

@interface TradeExecutor()

@property (nonatomic, strong) BaseTrade *trade;

@end

@implementation TradeExecutor

- (instancetype)init {
    self = [super init];
    if (self) {
        self.trade = [BaseTrade new];
    }
    return self;
}

- (BOOL)ext_canHandleJSMessage:(ExtJSMessage *)message {
    return YES;
}

- (id)ext_handleJSSyncMessage:(ExtJSMessage *)message {
    return @1;
}

- (void)ext_handleJSAsyncMessage:(ExtJSMessage *)message callback:(ExtJSCallbackStatus(^)(id result))callback {
    callback(@NO);
}

@end
