//
//  ExtJSCleanUpTask.h
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExtJSCleanUpTask : NSObject

@property (nonatomic, assign) BOOL cancel;

- (instancetype)initWithDeallocBlock:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
