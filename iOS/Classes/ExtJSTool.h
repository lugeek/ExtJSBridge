//
//  ExtJSTool.h
//  ExtJSBridge
//
//  Created by hang_pan on 2020/8/20.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ExtJSArgumentID;
extern NSString * const ExtJSArgumentTimestamp;
extern NSString * const ExtJSArgumentTarget;
extern NSString * const ExtJSArgumentAction;
extern NSString * const ExtJSArgumentValue;
extern NSString * const ExtJSArgumentValueType;
extern NSString * const ExtJSArgumentKind;

extern NSString * const ExtJSValueTypeString;
extern NSString * const ExtJSValueTypeNumber;
extern NSString * const ExtJSValueTypeBool;
extern NSString * const ExtJSValueTypeObject;
extern NSString * const ExtJSValueTypeArray;
extern NSString * const ExtJSValueTypeError;

@class ExtJSMessage, ExtJSNormalMessage;

@interface ExtJSTool : NSObject

+ (NSDictionary *)parseJSONString:(NSString *)parseJSONString;

+ (NSString *)valueTypeWithResult:(id)value;

+ (NSString *)valueWithResult:(id)value;

+ (NSString *)removeQueryAndFragmentWithURLString:(NSString *)URLString;

+ (BOOL)compareURLString:(NSString *)URLString withAnotherURLString:(NSString *)anotherURLString;

+ (NSString *)JSONFromResult:(id)result;

+ (NSString *)createCallbackJSWithResult:(id)result message:(ExtJSNormalMessage *)message;

+ (NSString *)createCleanUpCallbackJSWithMessage:(ExtJSNormalMessage *)message;

+ (NSString *)createSubscribeCallbackJSWithBridgeName:(NSString *)bridgeName targets:(NSArray<NSString *> *)targets action:(NSString *)action valueType:(NSString *)valueType value:(id)value;

@end

NS_ASSUME_NONNULL_END
