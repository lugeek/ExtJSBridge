//
//  JSContext+ExtJSBridge.h
//  AFNetworking
//
//  Created by hang_pan on 2020/8/20.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "ExtJSContextBridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface JSContext (ExtJSBridge)

@property (nonatomic, strong, readonly) ExtJSContextBridge *ext_bridge;

- (void)ext_initializeBridge;

@end

NS_ASSUME_NONNULL_END
