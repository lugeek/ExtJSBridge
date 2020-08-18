//
//  GeneralBuilder.h
//  Example
//
//  Created by hang_pan on 2020/8/18.
//  Copyright © 2020 hang_pan. All rights reserved.
//

#import "ExtJSExecutorBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface GeneralBuilder : ExtJSExecutorBuilder

@property (nonatomic, strong) NSMutableDictionary *executorCache;

@end

NS_ASSUME_NONNULL_END
