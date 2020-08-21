//
//  ExtJSExecutor.h
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/21.
//

#import <Foundation/Foundation.h>
#import "ExtJSMessage.h"
typedef NS_ENUM(NSInteger, ExtJSCallbackStatus) {
    ExtJSCallbackStatusSucceed = 0,
    ExtJSCallbackStatusURLChanged,
    ExtJSCallbackStatusResultInvalid
};

NS_ASSUME_NONNULL_BEGIN
@class ExtJSBridge;

@interface ExtJSExecutor : NSObject

@property (nonatomic, weak, readonly) ExtJSBridge *bridge;

- (instancetype)initWithBridge:(ExtJSBridge *)bridge;

- (void)didChangeValue:(id)value withAction:(NSString *)action;

//override by subclass
- (BOOL)verifyMessage:(ExtJSMessage *)message;
//override by subclass
- (nullable id)handleSyncMessage:(ExtJSNormalMessage *)message;
//override by subclass
- (void)handleAsyncMessage:(ExtJSNormalMessage *)message callback:(ExtJSCallbackStatus(^)(__nullable id result))callback;
//override by subclass
+ (NSArray <NSString *> *)executorNames;

@end

NS_ASSUME_NONNULL_END
