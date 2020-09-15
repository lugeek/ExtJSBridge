installModule(names) {
    if (!(names instanceof String) && typeof names != 'string' && !(names instanceof Array)) {
        console.error("TypeError: invalid names type" + typeof names);
        return;
    }
    if (!(names instanceof Array)) {
        names = [names];
    }
    let moduleNameSet = new Set();
    for (var i = 0; i < names.length; i++) {
        var name = names[i];
        var moduleClass = ext._mcm.get(name);
        if (moduleClass == null) {
            moduleNameSet.add(name);
        }
    }
    if (moduleNameSet.size == 0) {
        return true;
    }
    let result = ext._i("loader", "installModule", Array.from(moduleNameSet));
    if (result == null || result == undefined) {
        console.error("InstallModuleError: failed with module [" + Array.from(moduleNameSet) + "]");
        return false;
    }
    var code = "";
    for (let name in result) {
        let item = result[name];
        code += ext._cimc(item, name);
        moduleNameSet.delete(name);
    }
    ext._globalObject.eval(code);
    if (moduleNameSet.size > 0) {
        console.error("InstallModuleError: failed with module [" + Array.from(moduleNameSet)) + "]";
    }
    return true;
}