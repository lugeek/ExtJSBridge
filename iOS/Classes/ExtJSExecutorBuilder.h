//
//  ExtJSExecutorBuilder.h
//  ExtJSBridge
//
//  Created by Pn-X on 2020/8/15.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "ExtJSExecutorProtocol.h"
#import "ExtJSMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExtJSExecutorBuilder : NSObject

// find/create a useable executor to handle message; override by subclass; method will be called on child thread
// resolve Class :  NotifyExecutor -> Notify -> notify
// create instance : +[aClass singleton] -> +[aClass shared] -> -[[aClass alloc] init]
- (nullable id<ExtJSExecutorProtocol>)buildExecutorWithMessage:(ExtJSMessage *)message;

@end

NS_ASSUME_NONNULL_END
