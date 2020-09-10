//
//  ExtJSToolBox.m
//  Pods-Example
//
//  Created by Pn-X on 2020/8/23.
//

#import "ExtJSToolBox.h"
#import "ExtJSModule.h"

ExtJSValueType * const ExtJSValueTypeString = @"S";
ExtJSValueType * const ExtJSValueTypeNumber = @"N";
ExtJSValueType * const ExtJSValueTypeBool = @"B";
ExtJSValueType * const ExtJSValueTypeObject = @"O";
ExtJSValueType * const ExtJSValueTypeArray = @"A";
ExtJSValueType * const ExtJSValueTypeError = @"E";

ExtJSCallbackFunction * const ExtJSCallbackFunctionProgress = @"_p";
ExtJSCallbackFunction * const ExtJSCallbackFunctionSuccess = @"_s";
ExtJSCallbackFunction * const ExtJSCallbackFunctionFail = @"_f";

#define JSON_TRUE @"true"
#define JSON_FALSE @"false"

@implementation ExtJSToolBox
+ (NSCharacterSet *)allowedCharacterSet  {
    static NSMutableCharacterSet *allowedCharacterSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:@"/"];
    });
    return allowedCharacterSet;
}

+ (ExtJSCompactValue *)convertNativeValue:(nullable id)value {
    NSString *valueType = ExtJSValueTypeString;
    if ([value isKindOfClass:[NSString class]]) {
        value = [value stringByAddingPercentEncodingWithAllowedCharacters:self.allowedCharacterSet];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        valueType = ExtJSValueTypeNumber;
        value = [NSString stringWithFormat:@"%@", value];
    } else if ([value isKindOfClass:[NSError class]] || [value isKindOfClass:[NSException class]]) {
        valueType = ExtJSValueTypeError;
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
        valueType = ExtJSValueTypeArray;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:0 error:nil];
        if (jsonData) {
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        valueType = ExtJSValueTypeArray;
        NSArray *array = [(NSSet *)value allObjects];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
        if (jsonData) {
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        valueType = ExtJSValueTypeObject;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:0 error:nil];
        if (jsonData) {
            value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    return [NSString stringWithFormat:@"%@/%@", valueType, value];
}

+ (nullable id)convertcompactValue:(ExtJSCompactValue *)value {
    NSArray *array = [value componentsSeparatedByString:@"/"];
    NSString *valueType = ExtJSValueTypeString;
    if (array.count > 0) {
        valueType = array[0];
    }
    if (array.count > 1) {
        value = [self convertValue:value valueType:valueType];
    }
    return value;
}

+ (nullable id)convertValue:(NSString *)value valueType:(NSString *)valueType {
    if ([valueType isEqualToString:ExtJSValueTypeError]) {
        NSData *jsonData = [value.stringByRemovingPercentEncoding dataUsingEncoding:NSUTF8StringEncoding];
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
        NSData *jsonData = [value.stringByRemovingPercentEncoding dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        if (![array isKindOfClass:[NSArray class]]) {
            return nil;
        }
        return array;
    }
    if ([valueType isEqualToString:ExtJSValueTypeObject]) {
        NSData *jsonData = [value.stringByRemovingPercentEncoding dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        return dic;
    }
    if ([valueType isEqualToString:ExtJSValueTypeBool]) {
        if ([value isEqualToString:JSON_TRUE]) {
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
        value = value.stringByRemovingPercentEncoding;
        NSNumber *number = nil;
        [formatter getObjectValue:&number forString:value range:nil error:nil];
        return number != nil ? number : @0;
    }
    if ([valueType isEqualToString:ExtJSValueTypeString]) {
        return [value stringByRemovingPercentEncoding];
    }
    return nil;
}

+ (NSString *)createJSModuleClassFromModuleClass:(Class)moduleClass {
    NSString *name = [moduleClass moduleName];
    NSDictionary *methods = [moduleClass exportMethods];
    NSMutableString *methodString = [NSMutableString string];
    for (NSString *methodName in methods) {
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

+ (ExtJSCompactSession *)createCompactSessionWithTarget:(NSString *)target
                                                 action:(NSString *)action
                                                    sID:(NSString *)sID
                                           compactValue:(ExtJSCompactValue *)compactValue {
    return [NSString stringWithFormat:@"%@/%@/%@/%@", target, action, sID, compactValue];
}

+ (ExtJSCompactSession *)createCompactSessionWithTarget:(NSString *)target
                                                 action:(NSString *)action
                                                    sID:(NSString *)sID
                                              valueType:(NSString *)valueType
                                                  value:(NSString *)value {
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@", target, action, sID, valueType, value];
}

+ (ExtJSRunnableJS *)createRunnableJSWithBridgeName:(NSString *)bridgeName function:(ExtJSCallbackFunction *)function compactSession:(ExtJSCompactSession *)compactSession {
    return [NSString stringWithFormat:@"%@.%@(\"%@\")", bridgeName, function, compactSession];
}

+ (ExtJSRunnableJS *)createleRunnableJSWithBridgeName:(NSString *)bridgeName target:(NSString *)target message:(NSString *)message compactValue:(ExtJSCompactValue *)compactValue {
    return [NSString stringWithFormat:@"%@._mim.get(\"%@\").channel.post(\"%@\", \"%@\")", bridgeName, target, message, compactValue];
}
@end
