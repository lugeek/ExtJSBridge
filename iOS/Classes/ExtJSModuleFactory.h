//
//  ExtJSModuleFactory.h
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class ExtJSModule;

@interface ExtJSModuleFactory : NSObject

+ (instancetype)singleton;

- (void)registerModuleClass:(Class)moduleClass;

- (void)registerModuleClasses:(NSArray <Class> *)moduleClasses;

- (Class)moduleClassWithName:(NSString *)name;

- (NSSet *)moduleMessagesWithName:(NSString *)name;

- (NSDictionary *)moduleMethodsWithName:(NSString *)name;

- (NSString *)JSModuleClassWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
