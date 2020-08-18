//
//  GeneralSecurity.m
//  Example
//
//  Created by hang_pan on 2020/8/18.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "GeneralSecurity.h"

@implementation GeneralSecurity

- (void)verifyMessage:(ExtJSMessage *)message complete:(void(^)(BOOL passed))complete {
    if ([[self protectTargetList] containsObject:message.target]) {
        complete(NO);
    }
    if ([[self protectActionList] containsObject:message.action]) {
        complete(NO);
    }
    if ([[self blackDomainList] containsObject:[NSURL URLWithString:message.compactURLString].host]) {
        complete(NO);
    }
    complete(YES);
}

- (NSArray *)protectTargetList {
    return @[
        @"trade",
        @"userCenter",
    ];
}

- (NSArray *)protectActionList {
    return @[
        @"getPhone",
    ];
}

- (NSArray *)blackDomainList {
    return @[
        @"www.taobao.com",
        @"www.baidu.com"
    ];
}
@end
