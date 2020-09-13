//
//  ExtJSBridge.h
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ExtJSModule;

extern NSString * const ExtJSBridgeDefaultName;

@interface ExtJSBridge : NSObject

@property (nonatomic, strong, readonly) NSString *name;

//cache all module instance, use it cafully
@property (nonatomic, strong, readonly) NSDictionary *moduleInstanceCache;

- (instancetype)initWithName:(NSString *)name;

//load core, do not use it
- (id)loadCore;

@end

NS_ASSUME_NONNULL_END
