//
//  ExtJSCoreBridge.m
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/21.
//


#import "ExtJSCoreBridge.h"

@protocol ExtJSCoreExport <JSExport>

JSExportAs(invoke, - (id)invokeTarget:(NSString *)target action:(NSString *)action params:(id)params);

@end

@interface ExtJSCoreBridge()<ExtJSCoreExport>

@end

@implementation ExtJSCoreBridge

- (instancetype)init {
    @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
}

- (instancetype)initWithName:(NSString *)name context:(JSContext *)context {
    NSAssert(name.length > 0, @"[ExtJSBridge]Invalid bridge message");
    NSAssert(context != nil, @"[ExtJSBridge]Invalid context");
    self = [super initWithName:name];
    if (self) {
        _context = context;
    }
    return self;
}

#pragma mark - ExtJSCoreExport
- (id)invokeTarget:(NSString *)target action:(NSString *)action params:(id)params {
    return nil;
}

@end
