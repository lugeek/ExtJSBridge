//
//  ExtJSCleaner.m
//  ExtJSBridge
//
//  Created by Pn-X on 2020/8/25.
//

#import "ExtJSCleaner.h"

@implementation ExtJSCleaner

- (instancetype)initWithDeallocBlock:(dispatch_block_t)block {
    self = [super init];
    if (self) {
        _block = block;
    }
    return self;
}

- (void)dealloc {
    if (!_cancel && _block) {
        _block();
    }
}
@end
