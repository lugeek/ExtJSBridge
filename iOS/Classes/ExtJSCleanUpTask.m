//
//  ExtJSCleanUpTask.m
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/21.
//

#import "ExtJSCleanUpTask.h"

@interface ExtJSCleanUpTask()
    
@property (nonatomic, copy) dispatch_block_t block;

@end

@implementation ExtJSCleanUpTask

- (instancetype)initWithDeallocBlock:(dispatch_block_t)block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

- (void)dealloc {
    if (!_cancel && _block) {
        _block();
    }
}
@end
