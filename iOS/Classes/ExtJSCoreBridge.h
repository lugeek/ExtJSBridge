//
//  ExtJSCoreBridge.h
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/21.
//

#import "ExtJSBridge.h"
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExtJSCoreBridge : ExtJSBridge

//the connected context
@property (nonatomic, weak, nullable, readonly) JSContext *context;

- (instancetype)initWithName:(NSString *)name context:(JSContext *)context;

@end

NS_ASSUME_NONNULL_END
