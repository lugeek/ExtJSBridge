//
//  EnvModule.m
//  Example
//
//  Created by Pn-X on 2020/8/24.
//  Copyright © 2020 pn-x. All rights reserved.
//

#import "EnvModule.h"

@implementation EnvModule

- (id)platformSync:(id)arg {
    return @"iOS";
}

- (void)platform:(id)arg callback:(ExtJSCallback)callback {
    callback(ExtJSCallbackFunctionSuccess, @"iOS");
}

- (void)networkType:(id)arg callback:(ExtJSCallback)callback {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        callback(ExtJSCallbackFunctionProgress, @"WIFI");
    });
}

+ (NSDictionary *)exportMethods {
    return @{
        @"platformSync":@YES,
        @"platform":@NO,
        @"networkType":@NO,
    };
}

+ (NSString *)moduleName {
    return @"env";
}

@end
