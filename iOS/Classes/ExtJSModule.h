//
//  ExtJSModule.h
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import <Foundation/Foundation.h>
#import "ExtJSToolBox.h"

NS_ASSUME_NONNULL_BEGIN

#define EXT_JS_SYNC_METHOD(methodName) -(id)methodName:(id)arg
#define EXT_JS_ASYNC_METHOD(methodName) -(id)methodName:(id)arg callback:(ExtJSCallback)callback

@class ExtJSBridge;

@interface ExtJSModule : NSObject

@property (nonatomic, weak, readonly) ExtJSBridge *bridge;
@property (nonatomic, copy, readonly) NSString *name;

- (instancetype)initWithBridge:(ExtJSBridge *)bridge;

//post message to javascript
- (void)postMessage:(NSString *)message object:(nullable id)object;

//override by subclass, you can reset your module state here
- (void)handleURLChanged:(NSURL *)URL;
//override by subclass
+ (NSArray *)exportMessages;
//override by subclass, @key:methodName @value:isSync
+ (NSDictionary *)exportMethods;
//override by subclass, reserved name: @"bin"
+ (NSString *)moduleName;
//override by subclass
+ (NSString *)moduleDescription;

@end

NS_ASSUME_NONNULL_END
