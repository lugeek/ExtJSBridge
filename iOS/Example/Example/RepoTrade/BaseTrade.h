//
//  BaseTrade.h
//  Example
//
//  Created by hang_pan on 2020/8/18.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//A pod do not support ExtJSMessage
@interface BaseTrade : NSObject

- (NSString *)createOrderWithProductIds:(NSArray *)productIds;

- (void)payForOrderId:(NSString *)orderId complete:(dispatch_block_t)complete;

@end

NS_ASSUME_NONNULL_END
