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

//override by subclass; method may called on child thread
//return NO to ignore this message
- (BOOL)verifyMessage:(ExtJSMessage *)message;

@end

NS_ASSUME_NONNULL_END
