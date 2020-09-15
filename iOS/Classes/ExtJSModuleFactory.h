//
//  ExtJSModuleFactory.h
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class ExtJSModule;

@interface ExtJSModuleInfo : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *JSModuleClass;
@property (nonatomic, strong, readonly) Class cls;
@property (nonatomic, strong, readonly) NSDictionary *methodMap;
@property (nonatomic, strong, readonly) NSMutableSet *messageSet;
@property (nonatomic, assign, readonly) BOOL isCoreModule;

@end

@interface ExtJSModuleFactory : NSObject

+ (instancetype)singleton;

- (void)registerModuleClass:(Class)moduleClass;

- (void)registerModuleClasses:(NSArray <Class> *)moduleClasses;

- (ExtJSModuleInfo *)moduleInfoWithName:(NSString *)name;

- (NSDictionary <NSString *, ExtJSModuleInfo *> *)allCoreModuleInfo;

@end

NS_ASSUME_NONNULL_END
