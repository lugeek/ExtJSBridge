//
//  TradeExecutor.m
//  Example
//
//  Created by hang_pan on 2020/8/13.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "TradeExecutor.h"
#import "BaseTrade.h"
#import <ExtJSBridge/ExtJSBridgeHeader.h>

@interface TradeExecutor()<ExtJSExecutorProtocol>

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

- (void)ext_handleJSMessage:(ExtJSMessage *)message {
    if (message.kind != ExtJSMessageKindNormal) {
        return;
    }
    if ([message.action isEqualToString:@"createOrder"]) {
        NSArray *array = message.value[@"list"];
        NSString *orderId = [self.trade createOrderWithProductIds:array];
        [message callbackWithParams:orderId complete:nil];
        return;
    }
    if ([message.action isEqualToString:@"pay"]) {
        [self.trade payForOrderId:message.value complete:^{
            [message callbackWithParams:@(true) complete:nil];
        }];
    }
}

@end
