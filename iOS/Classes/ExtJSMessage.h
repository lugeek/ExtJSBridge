//
//  ExtJSMessage.h
//  ExtJS
//
//  Created by Pn-X on 2020/8/15.
//

#import <Foundation/Foundation.h>
#import "ExtJSTool.h"


NS_ASSUME_NONNULL_BEGIN

@class ExtJSBridge;

@interface ExtJSMessage : NSObject

@property (nonatomic, strong, readonly) NSString *target;

@property (nonatomic, strong, readonly) NSString *action;

@property (nonatomic, strong, readonly) NSString *mID;

@property (nonatomic, strong, readonly) NSString *timestamp;

@property (nonatomic, strong, readonly) WKFrameInfo *frameInfo;

@property (nonatomic, weak, readonly, nullable) ExtJSBridge *bridge;

@property (nonatomic, strong, readonly) NSString *compactURLString; //without query and fragment

- (instancetype)initWithTarget:(NSString *)target
                      action:(NSString *)action
                         mID:(NSString *)mID
                   timestamp:(NSString *)timestamp
                   frameInfo:(WKFrameInfo *)frameInfo
            compactURLString:(NSString *)compactURLString
                      bridge:(ExtJSBridge *)bridge;

@end

@interface ExtJSNormalMessage : ExtJSMessage

@property (nonatomic, strong, readonly, nullable) NSString *valueType;

@property (nonatomic, strong, readonly, nullable) id value;

@property (nonatomic, strong, readonly) NSString *uniqueMessageKey;

@property (nonatomic, assign, readonly) BOOL isSync;

- (instancetype)initWithTarget:(NSString *)target
                        action:(NSString *)action
                           mID:(NSString *)mID
                     timestamp:(NSString *)timestamp
                     valueType:(NSString *)valueType
                         value:(id)value
                        isSync:(BOOL)isSync
                     frameInfo:(WKFrameInfo *)frameInfo
              compactURLString:(NSString *)compactURLString
                        bridge:(ExtJSBridge *)bridge;
@end

@interface ExtJSSubscribeMessage : ExtJSMessage

@property (nonatomic, strong, readonly) NSString *subscribeKey;

@end

NS_ASSUME_NONNULL_END
