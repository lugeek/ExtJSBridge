//
//  ExtJSSession.h
//  ExtJSBridge
//
//  Created by hang_pan on 2020/9/1.
//

#import <Foundation/Foundation.h>
#import "ExtJSToolBox.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExtJSSession : NSObject

@property (nonatomic, copy, readonly) NSString *target;

@property (nonatomic, copy, readonly) NSString *action;

@property (nonatomic, copy, readonly) NSString *sID;

@property (nonatomic, copy, readonly, nullable) NSString *valueType;

@property (nonatomic, strong, readonly, nullable) id value;

@property (nonatomic, copy, readonly) NSString *compactSession;

// compactSession format: target/action/sID/valueType/value
- (instancetype)initWithCompactSession:(ExtJSCompactSession *)compactSession;

@end

NS_ASSUME_NONNULL_END
