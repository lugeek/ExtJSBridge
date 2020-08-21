//
//  Networking.h
//  Example
//
//  Created by hang_pan on 2020/8/13.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <AFNetworking/AFNetworking.h>
#import <ExtJSBridge/ExtJSBridgeHeader.h>

@protocol NetworkingListenerProtocol <NSObject>

- (void)didChangedNetworkingStatus:(AFNetworkReachabilityStatus)status;

@end
NS_ASSUME_NONNULL_BEGIN

@interface Networking : ExtJSExecutor

- (void)post:(NSDictionary *)params successBlock:(void(^)(id result))successBlock errorBlock:(void(^)(NSError *error))errorBlock;

- (void)get:(NSDictionary *)params callback:(void(^)(id result, NSError *error))callback;

@end

NS_ASSUME_NONNULL_END
