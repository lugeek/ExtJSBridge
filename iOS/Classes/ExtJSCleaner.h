//
//  ExtJSCleaner.h
//  ExtJSBridge
//
//  Created by Pn-X on 2020/8/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExtJSCleaner : NSObject

@property (nonatomic, assign) BOOL cancel;

@property (nonatomic, copy) dispatch_block_t block;

- (instancetype)initWithDeallocBlock:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
