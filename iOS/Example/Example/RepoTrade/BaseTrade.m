//
//  BaseTrade.m
//  Example
//
//  Created by hang_pan on 2020/8/18.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "BaseTrade.h"

@implementation BaseTrade

- (NSString *)createOrderWithProductIds:(NSArray *)productIds {
    return @"123";
}

- (void)payForOrderId:(NSString *)orderId complete:(dispatch_block_t)complete {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        complete();
    });
}
@end
