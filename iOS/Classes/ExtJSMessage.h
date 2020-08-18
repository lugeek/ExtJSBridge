//
//  ExtJSMessage.h
//  ExtJS
//
//  Created by Pn-X on 2020/8/15.
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

typedef NS_ENUM(NSInteger, ExtJSMessageKind) {
    ExtJSMessageKindNormal = 0,
    ExtJSMessageKindSubscribe,
    ExtJSMessageKindUnsubscribe,
};

typedef NS_ENUM(NSInteger, ExtJSCallbackFailedReason) {
    ExtJSCallbackFailedReasonUnkown = 0,
    ExtJSCallbackFailedReasonWebViewDestroyed,
    ExtJSCallbackFailedReasonURLChanged,
    ExtJSCallbackFailedReasonParamInvalid,
    ExtJSCallbackFailedReasonUnsupported,
    ExtJSCallbackFailedReasonHasInvoked
};

@interface ExtJSMessage : NSObject

@property (nonatomic, assign, readonly) ExtJSMessageKind kind;

@property (nonatomic, strong, readonly) NSString *target;

@property (nonatomic, strong, readonly) NSString *action;

@property (nonatomic, strong, readonly) NSString *mID;

@property (nonatomic, strong, readonly) NSString *timestamp;

@property (nonatomic, strong, readonly, nullable) NSString *valueType;

@property (nonatomic, strong, readonly, nullable) id value;

@property (nonatomic, strong, readonly) WKFrameInfo *frameInfo;

//urlstring without query and fragment
@property (nonatomic, strong, readonly) NSString * compactURLString;

@property (nonatomic, weak, readonly, nullable) WKWebView *webView;

@property (nonatomic, strong, readonly) NSString *bridgeName;

@property (nonatomic, strong, readonly) NSString *uniqueMessageKey;

@property (nonatomic, strong, readonly) NSString *uniqueSubscribeKey;

- (instancetype)initWithTarget:(NSString *)target action:(NSString *)action mID:(NSString *)mID timestamp:(NSString *)timestamp kind:(ExtJSMessageKind)kind valueType:(NSString *)valueType value:(id)value frameInfo:(WKFrameInfo *)frameInfo compactURLString:(NSString *)compactURLString webView:(WKWebView *)webView bridgeName:(NSString *)bridgeName queue:(dispatch_queue_t)queue;

//method should be called on main thread
//params must be kindof NSNumber(BOOL/Integer/Float), NSString,NSArray,NSDictionary,NSError
- (void)invokeCallbackWithParams:(id)params complete:(void(^_Nullable)(BOOL success, ExtJSCallbackFailedReason reason))complete;

+ (NSDictionary *)parseRawString:(NSString *)parseRawString;

+ (NSString *)URLStringWithoutQueryAndFragment:(NSString *)URLString;

@end

NS_ASSUME_NONNULL_END
