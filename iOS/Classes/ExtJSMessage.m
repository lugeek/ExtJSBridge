//
//  ExtJSMessage.m
//  ExtJS
//
//  Created by Pn-X on 2020/8/15.
//

#import "ExtJSMessage.h"
#import <CommonCrypto/CommonDigest.h>

@implementation ExtJSMessage

- (instancetype)initWithTarget:(NSString *)target
                        action:(NSString *)action
                           mID:(NSString *)mID
                     timestamp:(NSString *)timestamp
                     frameInfo:(WKFrameInfo *)frameInfo
              compactURLString:(NSString *)compactURLString
                        bridge:(ExtJSBridge *)bridge {
    self = [super init];
    if (self) {
        _target = target;
        _action = action;
        _mID = mID;
        _timestamp = timestamp;
        _frameInfo = frameInfo;
        _compactURLString = compactURLString;
        _bridge = bridge;
    }
    return self;
}

@end

@implementation ExtJSNormalMessage

- (instancetype)initWithTarget:(NSString *)target
                        action:(NSString *)action
                           mID:(NSString *)mID
                     timestamp:(NSString *)timestamp
                     valueType:(NSString *)valueType
                         value:(id)value
                        isSync:(BOOL)isSync
                     frameInfo:(WKFrameInfo *)frameInfo
              compactURLString:(NSString *)compactURLString
                        bridge:(ExtJSBridge *)bridge {
    self = [super initWithTarget:target action:action mID:mID timestamp:timestamp frameInfo:frameInfo compactURLString:compactURLString bridge:bridge];
    if (self) {
        _valueType = valueType;
        _value = value;
        _isSync = isSync;
        _uniqueMessageKey = [NSString stringWithFormat:@"%@-%@-%@-%@", target, action, mID, compactURLString];
    }
    return self;
}

@end

@implementation ExtJSSubscribeMessage

- (instancetype)initWithTarget:(NSString *)target
                        action:(NSString *)action
                           mID:(NSString *)mID
                     timestamp:(NSString *)timestamp
                     frameInfo:(WKFrameInfo *)frameInfo
              compactURLString:(NSString *)compactURLString
                        bridge:(ExtJSBridge *)bridge {
    self = [super initWithTarget:target action:action mID:mID timestamp:timestamp frameInfo:frameInfo compactURLString:compactURLString bridge:bridge];
    if (self) {
        _subscribeKey = [NSString stringWithFormat:@"%@-%@", target, action];
    }
    return self;
}
@end
