//
//  EnvModule.m
//  Example
//
//  Created by Pn-X on 2020/8/24.
//  Copyright © 2020 pn-x. All rights reserved.
//

#import "EnvModule.h"

@implementation EnvModule

EXT_JS_SYNC_METHOD(platformSync) {
    return @"iOS";
}

EXT_JS_ASYNC_METHOD(platform) {
    callback(ExtJSCallbackFunctionSuccess, @"iOS");
    return nil;
}

+ (NSDictionary *)exportMethods {
    return @{
        @"platformSync":@YES,
        @"platform":@NO,
    };
}

+ (NSString *)moduleName {
    return @"env";
}

@end
