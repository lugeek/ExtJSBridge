package com.pn_x.extjsbridge;

import com.pn_x.extjsbridge.modules.boot.ExtModule;
import com.pn_x.extjsbridge.modules.core.ExtLoaderModule;

import java.util.HashMap;
import java.util.Map;

public class ExtJSModuleFactory {

    private static ExtJSModuleFactory sInstance;

    private Map<String, Class<?>> moduleClasses;
    private Map<String, Class<?>> coreModules;

    public static ExtJSModuleFactory getsInstance() {
        synchronized (ExtJSModuleFactory.class) {
            if (sInstance == null) {
                sInstance = new ExtJSModuleFactory();
            }
        }
        return sInstance;
    }

    public ExtJSModuleFactory() {
        moduleClasses = new HashMap<>();
        initBootModules();
        initCoreModules();
        moduleClasses.putAll(coreModules);
    }

    private void initBootModules() {
        moduleClasses.put("ext", ExtModule.class);
    }

    private void initCoreModules() {
        coreModules = new HashMap<>();
        coreModules.put("loader", ExtLoaderModule.class);
    }

    public synchronized void registerModuleClass(String target, Class<?> clz) {
        moduleClasses.put(target, clz);
    }

    public synchronized void registerModuleClass(Map<String, Class<?>> map) {
        moduleClasses.putAll(map);
    }

    public Class<?> moduleClass(String target) {
        return moduleClasses.get(target);
    }

    public Map<String, Class<?>> getCoreModules() {
        return coreModules;
    }

    public synchronized void registerCoreModuleClass(String target, Class<?> clz) {
        coreModules.put(target, clz);
    }

    public synchronized void registerCoreModuleClass(Map<String, Class<?>> map) {
        coreModules.putAll(map);
    }

}
