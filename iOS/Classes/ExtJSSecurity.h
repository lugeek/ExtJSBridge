//
//  ExtJSSecurity.h
//  ExtJSBridge
//
//  Created by Pn-X on 2020/8/15.
//

#import <Foundation/Foundation.h>
#import "ExtJSMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExtJSSecurity : NSObject

//override by subclass; method will be called on child thread
- (void)verifyMessage:(ExtJSMessage *)message complete:(void(^)(BOOL passed))complete;

@end

NS_ASSUME_NONNULL_END
