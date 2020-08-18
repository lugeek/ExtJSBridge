//
//  ExtJSExecutorBuilder.m
//  ExtJSBridge
//
//  Created by Pn-X on 2020/8/15.
//

#import "ExtJSExecutorBuilder.h"

@implementation ExtJSExecutorBuilder

- (nullable id<ExtJSExecutorProtocol>)buildExecutorWithMessage:(ExtJSMessage *)message {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *rawTarget = message.target;
    NSString *capitalizedTarget = [message.target stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[message.target substringToIndex:1] capitalizedString]];
    NSString *appendTarget = [capitalizedTarget stringByAppendingString:@"Executor"];
    Class cls = NSClassFromString(appendTarget);
    if (!cls || ![cls conformsToProtocol:@protocol(ExtJSExecutorProtocol)]) {
        cls = NSClassFromString(capitalizedTarget);
        if (!cls || ![cls conformsToProtocol:@protocol(ExtJSExecutorProtocol)]) {
            if ([rawTarget isEqualToString:capitalizedTarget]) {
                return nil;
            }
            cls = NSClassFromString(rawTarget);
            if (!cls || ![cls conformsToProtocol:@protocol(ExtJSExecutorProtocol)]) {
                return nil;
            }
        }
    }
    id executor = nil;
    NSArray *sels = @[@"singleton", @"shared"];
    for (NSString *sel in sels) {
        SEL seletor = NSSelectorFromString(sel);
        if ([cls respondsToSelector:seletor]) {
            executor = [cls performSelector:seletor];
        }
    }
    if (executor == nil) {
        executor = [[cls alloc] init];
    }
    #pragma clang diagnostic pop
    return executor;
}

@end
