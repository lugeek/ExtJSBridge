package com.pn_x.extjsbridge.modules.boot;

import android.content.Context;

import com.pn_x.extjsbridge.ExtJSModuleFactory;
import com.pn_x.extjsbridge.ExtJSToolBox;
import com.pn_x.extjsbridge.IExtJSBridge;
import com.pn_x.extjsbridge.annotations.ExtSyncAction;

import java.util.HashMap;
import java.util.Map;

public class ExtModule {

    @ExtSyncAction("loadCore")
    public Map loadCore(IExtJSBridge bridge, Context context) {
        Map<String, String> map = new HashMap<>();
        for (String target : ExtJSModuleFactory.getsInstance().getCoreModules().keySet()) {
            Class<?> clz = ExtJSModuleFactory.getsInstance().moduleClass(target);
            String jsClass = ExtJSToolBox.getJSModuleClassCreator(clz, target, context);
            map.put(target, jsClass);
            bridge.saveModuleCache(target);
        }
        return map;
    }

}
