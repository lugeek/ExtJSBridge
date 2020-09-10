//
//  ExtJSToolBox.h
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString ExtJSValueType;
extern ExtJSValueType * const ExtJSValueTypeString;
extern ExtJSValueType * const ExtJSValueTypeNumber;
extern ExtJSValueType * const ExtJSValueTypeBool;
extern ExtJSValueType * const ExtJSValueTypeObject;
extern ExtJSValueType * const ExtJSValueTypeArray;
extern ExtJSValueType * const ExtJSValueTypeError;


typedef NSString ExtJSCallbackFunction;
extern ExtJSCallbackFunction * const ExtJSCallbackFunctionProgress;
extern ExtJSCallbackFunction * const ExtJSCallbackFunctionSuccess;
extern ExtJSCallbackFunction * const ExtJSCallbackFunctionFail;

typedef NSString ExtJSCompactSession;

typedef NSString ExtJSCompactValue;

typedef NSString ExtJSRunnableJS;

typedef void(^ExtJSCallback)(ExtJSCallbackFunction *function, _Nullable id result);

@class ExtJSModule, ExtJSSession;

@interface ExtJSToolBox : NSObject

+ (ExtJSCompactValue *)convertNativeValue:(nullable id)value;

+ (nullable id)convertcompactValue:(ExtJSCompactValue *)value;

+ (nullable id)convertValue:(NSString *)value valueType:(NSString *)valueType;

+ (NSString *)createJSModuleClassFromModuleClass:(Class)moduleClass;

+ (NSString *)removeQueryAndFragmentWithURLString:(NSString *)URLString;

+ (BOOL)compareURLString:(NSString *)URLString withAnotherURLString:(NSString *)anotherURLString;

+ (ExtJSCompactSession *)createCompactSessionWithTarget:(NSString *)target action:(NSString *)action sID:(NSString *)sID compactValue:(ExtJSCompactValue *)compactValue;

+ (ExtJSCompactSession *)createCompactSessionWithTarget:(NSString *)target action:(NSString *)action sID:(NSString *)sID valueType:(NSString *)valueType value:(NSString *)value;

+ (ExtJSRunnableJS *)createRunnableJSWithBridgeName:(NSString *)bridgeName function:(ExtJSCallbackFunction *)function compactSession:(ExtJSCompactSession *)compactSession;

+ (ExtJSRunnableJS *)createleRunnableJSWithBridgeName:(NSString *)bridgeName target:(NSString *)target message:(NSString *)message compactValue:(ExtJSCompactValue *)compactValue;
@end

NS_ASSUME_NONNULL_END
