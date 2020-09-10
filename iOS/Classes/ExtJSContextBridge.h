//
//  ExtJSContextBridge.h
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import "ExtJSBridge.h"
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExtJSContextBridge : ExtJSBridge
//the connected context
@property (nonatomic, weak, nullable, readonly) JSContext *context;

- (instancetype)initWithName:(NSString *)name context:(JSContext *)context;

@end

NS_ASSUME_NONNULL_END
