//
//  ExtJSSession.m
//  ExtJSBridge
//
//  Created by hang_pan on 2020/9/1.
//

#import "ExtJSSession.h"
#import "ExtJSToolBox.h"

@implementation ExtJSSession

- (instancetype)initWithCompactSession:(ExtJSCompactSession *)compactSession {
    self = [super init];
    if (self) {
        _compactSession = compactSession;
        NSArray *array = [compactSession componentsSeparatedByString:@"/"];
        if (array.count > 0) {
            _target = array[0];
        }
        if (array.count > 1) {
            _action = array[1];
        }
        if (array.count > 2) {
            _sID = array[2];
        }
        if (array.count > 3) {
            _valueType = array[3];
        }
        if (array.count > 4) {
            id obj = [ExtJSToolBox convertValue:array[4] valueType:_valueType];
            if (obj) {
                _value = obj;
            }
        }
    }
    return self;
}

@end
