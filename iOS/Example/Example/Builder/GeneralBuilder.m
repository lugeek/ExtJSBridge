//
//  GeneralBuilder.m
//  Example
//
//  Created by hang_pan on 2020/8/18.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "GeneralBuilder.h"

@implementation GeneralBuilder

- (instancetype)init{
    self = [super init];
    if (self) {
        self.executorCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id<ExtJSExecutorProtocol>)buildExecutorWithMessage:(ExtJSMessage *)message {
    if (self.executorCache[message.target] != nil) {
        return self.executorCache[message.target];
    }
    NSString *clsName = [self targetExecutorMap][message.target];
    if (clsName) {
        Class cls = NSClassFromString(clsName);
        id obj = [[cls alloc] init];
        self.executorCache[message.target] = obj;
        return obj;
    }
    id obj = [super buildExecutorWithMessage:message];
    if (!obj) {
        return nil;
    }
    self.executorCache[message.target] = obj;
    return obj;
}

//you can read map from configure file such as JSON/YAML/PLIST
- (NSDictionary *)targetExecutorMap {
    return @{
        @"alert":@"AlertTest",
        @"Alert":@"AlertTest"
    };
}

@end
