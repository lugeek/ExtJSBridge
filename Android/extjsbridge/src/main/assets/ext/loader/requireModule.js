requireModule(name){
    var instance = ext._mim.get(name);
    if (!instance) {
        var moduleClass = ext._mcm.get(name);
        if (!moduleClass) {
            let state = ext.loader.installModule(name);
            if (!state) {
                return null;
            }
            moduleClass = ext._mcm.get(name);
        }
        instance = new moduleClass;
        instance.channel = new ExtMessageChannel;
        ext._mim.set(name, instance);
        ext._i("loader", "requireModule", name);
    }
    return instance;
}