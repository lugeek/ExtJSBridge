//
//  ExtJSBridge.h
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ExtJSModule;

@interface ExtJSBridge : NSObject

@property (nonatomic, strong, readonly) NSString *name;

- (instancetype)initWithName:(NSString *)name;

- (nullable ExtJSModule *)moduleInstanceWithName:(NSString *)moduleName;

- (void)removeModuleInstanceWithName:(NSString *)moduleName;

@end

NS_ASSUME_NONNULL_END
