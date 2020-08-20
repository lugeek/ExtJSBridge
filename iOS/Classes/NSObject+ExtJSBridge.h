//
//  NSObject+ExtJSBridge.h
//  AFNetworking
//
//  Created by hang_pan on 2020/8/20.
//

#import <Foundation/Foundation.h>
#import "ExtJSMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ExtJSBridge)

@property (nonatomic, strong, setter=ext_setJSSubscriberMap:) NSDictionary *ext_JSSubscriberMap;

- (void)ext_subscribeWithJSMessage:(ExtJSMessage *)message;

- (void)ext_unsubscribeWithJSMessage:(ExtJSMessage *)message;

- (void)ext_callBackToJSSubscriberWithAction:(NSString *)action params:(id)params;

@end

NS_ASSUME_NONNULL_END
