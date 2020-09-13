//
//  ExtJSToolBox.m
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import "ExtJSToolBox.h"
#import "ExtJSModule.h"
#import "ExtJSCoreModule.h"

ExtJSValueType * const ExtJSValueTypeString = @"S";
ExtJSValueType * const ExtJSValueTypeNumber = @"N";
ExtJSValueType * const ExtJSValueTypeBool = @"B";
ExtJSValueType * const ExtJSValueTypeObject = @"O";
ExtJSValueType * const ExtJSValueTypeArray = @"A";
ExtJSValueType * const ExtJSValueTypeError = @"E";

ExtJSCallbackFunction * const ExtJSCallbackFunctionProgress = @"_p";
ExtJSCallbackFunction * const ExtJSCallbackFunctionSuccess = @"_s";
ExtJSCallbackFunction * const ExtJSCallbackFunctionFail = @"_f";

ExtJSSessionKey * const ExtJSSessionKeyTarget = @"target";
ExtJSSessionKey * const ExtJSSessionKeyAction = @"action";
ExtJSSessionKey * const ExtJSSessionKeySID = @"sID";
ExtJSSessionKey * const ExtJSSessionKeyValueType = @"valueType";
ExtJSSessionKey * const ExtJSSessionKeyValue = @"value";

ExtJSCompactValue * const ExtJSCompactValueTrue = @"B/true";
ExtJSCompactValue * const ExtJSCompactValueFalse = @"B/false";

#define JSON_TRUE @"true"
#define JSON_FALSE @"false"

@implementation ExtJSToolBox

+ (ExtJSValueType *)getValueType:(nullable id)value {
    assert(value == nil
           || [value isKindOfClass:[NSNull class]]
           || [value isKindOfClass:[NSString class]]
           || [value isKindOfClass:[NSAttributedString class]]
           || [value isKindOfClass:[NSNumber class]]
           || [value isKindOfClass:[NSError class]]
           || [value isKindOfClass:[NSException class]]
           || [value isKindOfClass:[NSArray class]]
           || [value isKindOfClass:[NSSet class]]
           || [value isKindOfClass:[NSDictionary class]]);
    
    if (value == nil || value == [NSNull null]) {
        return ExtJSValueTypeString;
    } else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSAttributedString class]]) {
        return ExtJSValueTypeString;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return ExtJSValueTypeNumber;
    } else if ([value isKindOfClass:[NSError class]] || [value isKindOfClass:[NSException class]]) {
        return ExtJSValueTypeError;
    } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSSet class]]) {
        return ExtJSValueTypeArray;
    }
    return ExtJSValueTypeObject;
}

+ (NSString *)convertValue:(nullable id)value {
    assert(value == nil
           || [value isKindOfClass:[NSNull class]]
           || [value isKindOfClass:[NSString class]]
           || [value isKindOfClass:[NSAttributedString class]]
           || [value isKindOfClass:[NSNumber class]]
           || [value isKindOfClass:[NSError class]]
           || [value isKindOfClass:[NSException class]]
           || [value isKindOfClass:[NSArray class]]
           || [value isKindOfClass:[NSSet class]]
           || [value isKindOfClass:[NSDictionary class]]);
    
    if (value == nil || value == [NSNull null]) {
        value = @"";
    } if ([value isKindOfClass:[NSString class]]) {
        
    } else if ([value isKindOfClass:[NSAttributedString class]]) {
        value = ((NSAttributedString *)value).string;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        value = [NSString stringWithFormat:@"%@", value];
    } else if ([value isKindOfClass:[NSError class]] || [value isKindOfClass:[NSException class]]) {
        NSString *name = @"";
        NSNumber *code = @(-1);
        NSString *message = @"";
        if ([value isKindOfClass:[NSException class]]) {
            name = [(NSException *)value name];
            message = [(NSException *)value reason];
        } else {
            name = [(NSError *)value domain];
            if ([(NSError *)value userInfo][NSLocalizedDescriptionKey]) {
                message = [(NSError *)value userInfo][NSLocalizedDescriptionKey];
            }
            if ([(NSError *)value userInfo][NSLocalizedFailureReasonErrorKey]) {
                message = [(NSError *)value userInfo][NSLocalizedFailureReasonErrorKey];
            }
            code = @([(NSError *)value code]);
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"n":name, @"m":message,@"c":code} options:0 error:nil];
        value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:0 error:nil];
        if (jsonData) {
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSArray *array = [(NSSet *)value allObjects];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
        if (jsonData) {
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    } else {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:0 error:nil];
        if (jsonData) {
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    return value;
}

+ (nullable id)convertStringValue:(NSString *)string valueType:(NSString *)valueType {
    if ([valueType isEqualToString:ExtJSValueTypeError]) {
        NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        NSString *name = dic[@"n"]?dic[@"n"]:@"";
        NSNumber *code = dic[@"c"]?dic[@"c"]:@(-1);
        NSString *message = dic[@"m"]?dic[@"m"]:@"";
        return [NSError errorWithDomain:name code:[code integerValue] userInfo:@{NSLocalizedDescriptionKey:message}];
    }
    if ([valueType isEqualToString:ExtJSValueTypeArray]) {
        NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        if (![array isKindOfClass:[NSArray class]]) {
            return nil;
        }
        return array;
    }
    if ([valueType isEqualToString:ExtJSValueTypeObject]) {
        NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        return dic;
    }
    if ([valueType isEqualToString:ExtJSValueTypeBool]) {
        if ([string isEqualToString:JSON_TRUE]) {
            return @(1);
        }
        return @(0);
    }
    if([valueType isEqualToString:ExtJSValueTypeNumber]) {
        static NSNumberFormatter *formatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formatter = [NSNumberFormatter new];
        });
        NSNumber *number = nil;
        [formatter getObjectValue:&number forString:string range:nil error:nil];
        return number != nil ? number : @0;
    }
    if ([valueType isEqualToString:ExtJSValueTypeString]) {
        return string;
    }
    return nil;
}

+ (NSArray *)compactValueKeyList {
    static NSArray *ExtJSToolBoxCompactValueKeyList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtJSToolBoxCompactValueKeyList = @[ExtJSSessionKeyValueType, ExtJSSessionKeyValue];
    });
    return ExtJSToolBoxCompactValueKeyList;
}

+ (ExtJSCompactValue *)compactValue:(id)value {
    return [NSString stringWithFormat:@"%@/%@", [self getValueType:value] ,[self convertValue:value]];
}

+ (nullable id)parseCompactValue:(ExtJSCompactValue *)string {
    assert([string isKindOfClass:[NSString class]]);
    if (string == nil || ![string isKindOfClass:[NSString class]]) {
        string = @"";
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:@{
        ExtJSSessionKeyValueType:ExtJSValueTypeString,
        ExtJSSessionKeyValue:string,
    }];
    NSUInteger length = string.length;
    NSUInteger start = 0;
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < length; i++) {
        if ([string characterAtIndex:i] == '/') {
            NSString *key = [self compactValueKeyList][index];
            NSString *value = [string substringWithRange:NSMakeRange(start,i-start)];
            result[key] = value;
            index++;
            start = i + 1;
            if (index + 1 == [self compactValueKeyList].count) {
                key = [self compactValueKeyList][index];
                value = [string substringFromIndex:start];
                result[key] = [self convertStringValue:value valueType:result[ExtJSSessionKeyValueType]];
                break;
            }
        }
    }
    return result;
}

+ (NSArray *)compactSessionKeyList {
    static NSArray *ExtJSToolBoxCompactSessionKeyList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtJSToolBoxCompactSessionKeyList = @[ExtJSSessionKeyTarget, ExtJSSessionKeyAction, ExtJSSessionKeySID, ExtJSSessionKeyValueType, ExtJSSessionKeyValue];
    });
    return ExtJSToolBoxCompactSessionKeyList;
}

//compact session to session
+ (ExtJSSession *)parseCompactSession:(ExtJSCompactSession *)compactSession {
    assert([compactSession isKindOfClass:[ExtJSCompactSession class]]);
    if (compactSession == nil || ![compactSession isKindOfClass:[NSString class]]) {
        compactSession = @"";
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:@{
        ExtJSSessionKeyValueType:ExtJSValueTypeString,
        ExtJSSessionKeyValue:compactSession,
    }];
    NSUInteger length = compactSession.length;
    NSUInteger start = 0;
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < length; i++) {
        if ([compactSession characterAtIndex:i] == '/') {
            NSString *key = [self compactSessionKeyList][index];
            NSString *value = [compactSession substringWithRange:NSMakeRange(start,i-start)];
            result[key] = value;
            index++;
            start = i + 1;
            if (index + 1 == [self compactSessionKeyList].count) {
                key = [self compactSessionKeyList][index];
                value = [compactSession substringFromIndex:start];
                result[key] = [self convertStringValue:value valueType:result[ExtJSSessionKeyValueType]];
                break;
            }
        }
    }
    return result;
}
//session to compact session
+ (ExtJSCompactSession *)compactSession:(ExtJSSession *)session {
    return [self compactSessionWithTarget:session[ExtJSSessionKeyTarget] action:session[ExtJSSessionKeyAction] sID:session[ExtJSSessionKeySID] valueType:session[ExtJSSessionKeyValueType] value:session[ExtJSSessionKeyValue]];
}
//compact session with args
+ (ExtJSCompactSession *)compactSessionWithTarget:(NSString *)target action:(NSString *)action sID:(NSString *)sID valueType:(NSString *)valueType value:(NSString *)value {
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@", target, action, sID, valueType, value];
}


+ (ExtJSRunnableJS *)createWithFunction:(ExtJSCallbackFunction *)function compactSession:(ExtJSCompactSession *)compactSession {
    return [NSString stringWithFormat:@"ext.%@(\"%@\")", function, compactSession];
}
+ (ExtJSRunnableJS *)createWithTarget:(NSString *)target message:(NSString *)message compactValue:(ExtJSCompactValue *)compactValue {
    return [NSString stringWithFormat:@"ext._mim.get(\"%@\").channel.post(\"%@\", \"%@\")", target, message, compactValue];
}
+ (NSString *)createJSModuleClassFromModuleClass:(Class)moduleClass {
    NSString *name = [moduleClass moduleName];
    NSDictionary *methods = [moduleClass exportMethods];
    NSMutableString *methodString = [NSMutableString string];
    BOOL mayHaveImpl = [moduleClass isSubclassOfClass:[ExtJSCoreModule class]];
    for (NSString *methodName in methods) {
        if (mayHaveImpl) {
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@", methodName, ExtJSMethodImplementSurfix]);
            if ([moduleClass respondsToSelector:selector]) {
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                NSString *implement = [moduleClass performSelector:selector];
                #pragma clang diagnostic pop
                if (implement)  {
                    [methodString appendString:implement];
                    continue;
                }
            }
        }
        BOOL isSync = [methods[methodName] integerValue];
        [methodString appendString:[NSString stringWithFormat:@"%@(arg){return ext._i(\"%@\",\"%@\",arg, %@)}", methodName, name, methodName, isSync?@"true":@"false"]];
    }
    return [NSString stringWithFormat:@"class _ {%@}", methodString];
}

+ (NSString *)removeQueryAndFragmentWithURLString:(NSString *)URLString {
    NSString *string = URLString;
    if ([string containsString:@"?"]) {
        string = [string componentsSeparatedByString:@"?"].firstObject;
    } else if ([string containsString:@"#"]) {
        string = [string componentsSeparatedByString:@"#"].firstObject;
    }
    return string;
}

+ (BOOL)compareURLString:(NSString *)URLString withAnotherURLString:(NSString *)anotherURLString {
    NSString *oldURLString = [self removeQueryAndFragmentWithURLString:URLString];
    NSString *newURLString = [self removeQueryAndFragmentWithURLString:anotherURLString];
    if ([oldURLString isEqualToString:newURLString]) {
        return YES;
    }
    return NO;
}

@end
