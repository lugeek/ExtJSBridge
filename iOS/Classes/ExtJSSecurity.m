//
//  ExtJSSecurity.m
//  ExtJSBridge
//
//  Created by Pn-X on 2020/8/15.
//

#import "ExtJSSecurity.h"

@implementation ExtJSSecurity

- (void)verifyMessage:(ExtJSMessage *)message complete:(void(^)(BOOL passed))complete {
    complete(YES);
}

@end
