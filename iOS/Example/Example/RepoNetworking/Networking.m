//
//  Networking.m
//  Example
//
//  Created by hang_pan on 2020/8/13.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "Networking.h"
#import <ExtJSBridge/ExtJSExecutorProtocol.h>
#import <ExtJSBridge/NSObject+ExtJSBridge.h>

@interface Networking()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) AFNetworkReachabilityManager *reachableManager;
@property (nonatomic, strong) NSMutableArray *deviceList;

@property (nonatomic, strong) NSMutableArray *listeners;

@end

@implementation Networking

- (instancetype)init {
    self = [super init];
    if (self) {
        self.manager = [[AFHTTPSessionManager alloc] init];
        self.reachableManager = [AFNetworkReachabilityManager manager];
        self.listeners = [NSMutableArray array];
        [self monitorNetwrokStatusChange];
    }
    return self;
}

- (void)monitorNetwrokStatusChange {
    __weak typeof(self) weakSelf = self;
    [self.reachableManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSArray *listeners = weakSelf.listeners;
        for (id<NetworkingListenerProtocol> listener in listeners) {
            if ([listener isKindOfClass:[ExtJSMessage class]]) {
                [listener didChangedNetworkingStatus:status];
            }
        }
        [weakSelf ext_callBackToJSSubscriberWithAction:@"onStateChange" params:@(status)];
    }];
    [self.reachableManager startMonitoring];
}

- (void)addListener:(id<NetworkingListenerProtocol>)listener {
    [self.listeners addObject:listener];
}

- (void)ext_handleJSMessage:(ExtJSMessage *)message {
    if ([message.action isEqualToString:@"post"]) {
        [self post:message.value successBlock:^(id  _Nonnull result) {
            [message callbackWithParams:result complete:nil];
        } errorBlock:^(NSError * _Nonnull error) {
            [message callbackWithParams:error complete:nil];
        }];
        return;
    }
    if ([message.action isEqualToString:@"status"]) {
        [message callbackWithParams:@(self.reachableManager.networkReachabilityStatus) complete:nil];
        return;
    }
}

- (void)post:(NSDictionary *)params successBlock:(void(^)(id result))successBlock errorBlock:(void(^)(NSError *error))errorBlock {
    [self.manager POST:@"" parameters:@{} headers:@{} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorBlock(error);
    }];
}

- (void)get:(NSDictionary *)params callback:(void(^)(id result, NSError *error))callback {
    [self.manager GET:@"" parameters:@{} headers:@{} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        callback(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(nil, error);
    }];
}

@end
