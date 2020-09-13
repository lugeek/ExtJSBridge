//
//  ExtJSLoaderModule.m
//  ExtJSBridge
//
//  Created by Pn-X on 2020/9/12.
//

#import "ExtJSLoaderModule.h"

EXT_JS_MODULE_AUTO_REGISTER(ExtJSLoaderModule)

@implementation ExtJSLoaderModule

EXT_JS_SYNC_METHOD(installModule) {
    if (![arg isKindOfClass:[NSArray class]]) {
        return @(NO);
    }
    NSArray *array = arg;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSString *name in array) {
        ExtJSModuleInfo *info = [[ExtJSModuleFactory singleton] moduleInfoWithName:name];
        if (info.isCoreModule) {
            continue;;
        }
        dic[name] = info.JSModuleClass;
    }
    return dic;
}

EXT_JS_SYNC_METHOD(requireModule) {
    if (![arg isKindOfClass:[NSString class]]) {
        return @(NO);
    }
    NSString *name = arg;
    ExtJSModule *moduleInstance = self.bridge.moduleInstanceCache[name];
    if (!moduleInstance) {
        ExtJSModuleInfo *info = [[ExtJSModuleFactory singleton] moduleInfoWithName:name];
        if (info.isCoreModule) {
            return @(NO);
        }
        if (info.cls) {
            moduleInstance = [[info.cls alloc] initWithBridge:self.bridge];
            ((NSMutableDictionary *)self.bridge.moduleInstanceCache)[name] = moduleInstance;
        }
    }
    if (!moduleInstance) {
        return @(NO);
    }
    return @(YES);
}

EXT_JS_METHOD_IMPLEMENT(installModule) {
    return @"\
        installModule (names) {\
            if (!(names instanceof String) && typeof names != 'string' && !(names instanceof Array)) {\
                console.error(\"TypeError: invalid names type\" + typeof names);\
                return;\
            }\
            if (!(names instanceof Array)) {\
                names = [names];\
            }\
            let moduleNameSet = new Set();\
            for (var i = 0; i < names.length; i++) {\
                var name = names[i];\
                var moduleClass = ext._mcm.get(name);\
                if (moduleClass == null) {\
                    moduleNameSet.add(name);\
                }\
            }\
            if (moduleNameSet.size == 0) {\
                return true;\
            }\
            for (let element of moduleNameSet) {\
                console.log(\"element\"+ element);\
            }\
            let result = ext._i(\"loader\", \"installModule\", Array.from(moduleNameSet));\
            console.log(\"result:\" + result);\
            if (result == null || result == undefined) {\
                console.error(\"InstallModuleError: failed with module [\" + Array.from(moduleNameSet) + \"]\");\
                return false;\
            }\
            var code = \"\";\
            for (let name in result) {\
                let item = result[name];\
                code += ext._cimc(item, name);\
                moduleNameSet.delete(name);\
            }\
            ext._globalObject.eval(code);\
            if (moduleNameSet.size > 0) {\
                console.error(\"InstallModuleError: failed with module [\" + Array.from(moduleNameSet)) + \"]\";\
            }\
            return true;\
        }\
    ";
}

EXT_JS_METHOD_IMPLEMENT(requireModule) {
    return @"\
        requireModule(name){\
            var instance = ext._mim.get(name);\
            if (!instance) {\
                var moduleClass = ext._mcm.get(name);\
                if (!moduleClass) {\
                    let state = ext.loader.installModule(name);\
                    if (!state) {\
                        return null;\
                    }\
                    moduleClass = ext._mcm.get(name);\
                }\
                instance = new moduleClass;\
                instance.channel = new ExtMessageChannel;\
                ext._mim.set(name, instance);\
                ext._i(\"loader\", \"requireModule\", name);\
            }\
            return instance;\
        }\
    ";
}

+ (NSDictionary *)exportMethods {
    return @{
        @"requireModule":@YES,
        @"installModule":@YES,
    };
}

+ (NSString *)moduleName {
    return @"loader";
}

@end
