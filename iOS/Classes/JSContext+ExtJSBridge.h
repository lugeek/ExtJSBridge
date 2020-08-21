//
//  JSContext+ExtJSBridge.h
//  AFNetworking
//
//  Created by hang_pan on 2020/8/20.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "ExtJSBridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface JSContext (ExtJSBridge)

@property (nonatomic, strong, readonly) ExtJSBridge *ext_bridge;

//default name ext
- (void)ext_initializeBridge;

- (void)ext_initializeBridgeWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
