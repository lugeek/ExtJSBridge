//
//  ExtJSBridge.m
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import "ExtJSBridge.h"

@implementation ExtJSBridge

- (instancetype)init {
    return [self  initWithName:@"ext"];
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

- (ExtJSModule *)moduleInstanceWithName:(NSString *)moduleName {
    return nil;
}

- (void)removeModuleInstanceWithName:(NSString *)moduleName {
    
}
@end
