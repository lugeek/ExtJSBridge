//
//  Networking.m
//  Example
//
//  Created by hang_pan on 2020/8/13.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "Networking.h"
@interface Networking()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) AFNetworkReachabilityManager *reachableManager;
@property (nonatomic, strong) NSMutableArray *deviceList;

@property (nonatomic, strong) NSMutableArray *listeners;

@end

@implementation Networking

- (instancetype)initWithBridge:(ExtJSBridge *)bridge {
    self = [super initWithBridge:bridge];
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
        [weakSelf didChangeValue:@(status) withAction:@"onStateChange"];
    }];
    [self.reachableManager startMonitoring];
}

- (void)addListener:(id<NetworkingListenerProtocol>)listener {
    [self.listeners addObject:listener];
}

- (BOOL)verifyMessage:(ExtJSMessage *)message {
    return YES;
}

- (nullable id)handleSyncMessage:(ExtJSNormalMessage *)message {
    return nil;
}

- (void)handleAsyncMessage:(ExtJSNormalMessage *)message callback:(ExtJSCallbackStatus(^)(__nullable id result))callback {
    if ([message.action isEqualToString:@"show"]) {
        NSString *title = message.value[@"title"];
        NSString *msg = message.value[@"message"];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }];
        [alertController addAction:cancel];
        UIResponder *responder = message.bridge.webView;
        while (responder.nextResponder) {
            responder = responder.nextResponder;
            if ([responder isKindOfClass:[UIViewController class]]) {
                break;
            }
        }
        if (responder) {
            [(UIViewController *)responder presentViewController:alertController animated:YES completion:nil];
        } else {
            callback(@YES);
        }
        return;
    }
    if ([message.action isEqualToString:@"status"]) {
        callback(@(self.reachableManager.networkReachabilityStatus));
    }
}

+ (NSArray <NSString *> *)executorNames {
    return @[@"network"];
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
