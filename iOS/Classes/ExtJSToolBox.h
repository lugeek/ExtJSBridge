//
//  ExtJSToolBox.h
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN
#ifdef DEBUG
#define EXT_TIME_PROFILER_LAUNCH(profiler) CFTimeInterval profiler = CACurrentMediaTime();
#define EXT_TIME_PROFILER_RECORD(profiler, desc) NSLog(@"EXT_TIME_PROFILER:[%s], time:[%.6f], desc:[%@]", #profiler, CACurrentMediaTime() - profiler, desc);
#else
#define EXT_TIME_PROFILER_LAUNCH(profiler)
#define EXT_TIME_PROFILER_RECORD(profiler)
#endif


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

//format: target/action/sID/valueType/value
typedef NSString ExtJSCompactSession;

typedef NSString ExtJSSessionKey;
typedef NSDictionary ExtJSSession;
extern ExtJSSessionKey * const ExtJSSessionKeyTarget;
extern ExtJSSessionKey * const ExtJSSessionKeyAction;
extern ExtJSSessionKey * const ExtJSSessionKeySID;
extern ExtJSSessionKey * const ExtJSSessionKeyValueType;
extern ExtJSSessionKey * const ExtJSSessionKeyValue;

//format: valueType/value
typedef NSString ExtJSCompactValue;
extern ExtJSCompactValue * const ExtJSCompactValueTrue;
extern ExtJSCompactValue * const ExtJSCompactValueFalse;

typedef NSString ExtJSRunnableJS;

typedef void(^ExtJSCallback)(ExtJSCallbackFunction *function, _Nullable id result);

@class ExtJSModule;

@interface ExtJSToolBox : NSObject

//get value type
+ (ExtJSValueType *)getValueType:(nullable id)value;

//native value to string value
+ (NSString *)convertValue:(nullable id)value;
//string value to native value
+ (nullable id)convertStringValue:(NSString *)string valueType:(NSString *)valueType;

//compact value to native value
+ (nullable id)parseCompactValue:(ExtJSCompactValue *)string;
//native value to compact value
+ (ExtJSCompactValue *)compactValue:(nullable id)value;

//compact session to session
+ (ExtJSSession *)parseCompactSession:(ExtJSCompactSession *)compactSession;
//session to compact session
+ (ExtJSCompactSession *)compactSession:(ExtJSSession *)session;
//compact session with args
+ (ExtJSCompactSession *)compactSessionWithTarget:(NSString *)target action:(NSString *)action sID:(NSString *)sID valueType:(NSString *)valueType value:(NSString *)value;

+ (ExtJSRunnableJS *)createWithFunction:(ExtJSCallbackFunction *)function compactSession:(ExtJSCompactSession *)compactSession;
+ (ExtJSRunnableJS *)createWithTarget:(NSString *)target message:(NSString *)message compactValue:(ExtJSCompactValue *)compactValue;
+ (NSString *)createJSModuleClassFromModuleClass:(Class)moduleClass;

//remove URL`s query an fragment
+ (NSString *)removeQueryAndFragmentWithURLString:(NSString *)URLString;
//compare to URL without query and fragment
+ (BOOL)compareURLString:(NSString *)URLString withAnotherURLString:(NSString *)anotherURLString;

@end

NS_ASSUME_NONNULL_END
