//
//  ExtJSCoreModule.h
//  ExtJSBridge
//
//  Created by Pn-X on 2020/9/12.
//

#import "ExtJSModule.h"
#import "ExtJSContextBridge.h"
#import "ExtJSWebViewBridge.h"
#import "ExtJSToolBox.h"
#import "ExtJSModuleFactory.h"

NS_ASSUME_NONNULL_BEGIN

#define EXT_JS_MODULE_AUTO_REGISTER(MODULE_CLS) __attribute__((constructor)) static void MODULE_CLS##AutoRegister(void) {\
    [[ExtJSModuleFactory singleton] registerModuleClass:[MODULE_CLS class]];\
}

#define EXT_JS_METHOD_IMPLEMENT(methodName) + (ExtJSMethodImplement *)methodName##JSMethodImplement

typedef NSString ExtJSMethodImplement;

extern NSString * const ExtJSMethodImplementSurfix;

//all core module should register to factory before any bridge allocated
@interface ExtJSCoreModule : ExtJSModule

@property (nonatomic, strong, readonly) NSString *globalObject;

@end

NS_ASSUME_NONNULL_END
