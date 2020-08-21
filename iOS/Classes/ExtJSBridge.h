//
//  ExtJSBridge.h
//  Pods-Example
//
//  Created by hang_pan on 2020/8/12.
//

#import <Foundation/Foundation.h>
#import "ExtJSSecurity.h"
#import "ExtJSExecutor.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExtJSBridge : NSObject 

//default ext
@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, strong, readonly) dispatch_queue_t queue;

//verify the message form webview to protect data
@property (nonatomic, strong) ExtJSSecurity *security;

+ (void)registExecutorClass:(Class)aClass;

- (instancetype)initWithName:(NSString *)name;

- (void)didChangeValue:(id)value withTargets:(NSArray <NSString *> *)targets action:(NSString *)action;

- (nullable ExtJSExecutor *)buildExecutorWithMessage:(ExtJSMessage *)message;

- (void)cleanUpExecutorCache;

@end

NS_ASSUME_NONNULL_END
