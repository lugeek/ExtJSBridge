package com.pn_x.extjsbridge;

import com.pn_x.extjsbridge.module.ExtBinModule;

import java.util.HashMap;
import java.util.Map;

public class ExtJSModuleFactory {

    private static ExtJSModuleFactory sInstance;

    private Map<String, Class<?>> modelClasses;

    public static ExtJSModuleFactory getsInstance() {
        synchronized (ExtJSModuleFactory.class) {
            if (sInstance == null) {
                sInstance = new ExtJSModuleFactory();
            }
        }
        return sInstance;
    }

    public ExtJSModuleFactory() {
        modelClasses = new HashMap<>();
        modelClasses.put("bin", ExtBinModule.class);
    }

    public synchronized void registerModuleClass(String target, Class<?> clz) {
        modelClasses.put(target, clz);
    }

    public synchronized void registerModelClass(Map<String, Class<?>> map) {
        modelClasses.putAll(map);
    }

    public Class<?> moduleClass(String target) {
        return modelClasses.get(target);
    }

}
