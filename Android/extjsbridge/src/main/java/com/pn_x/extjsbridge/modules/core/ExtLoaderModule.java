package com.pn_x.extjsbridge.modules.core;

import android.content.Context;

import com.pn_x.extjsbridge.ExtJSModuleFactory;
import com.pn_x.extjsbridge.ExtJSToolBox;
import com.pn_x.extjsbridge.IExtJSBridge;
import com.pn_x.extjsbridge.annotations.ExtActionJsImplement;
import com.pn_x.extjsbridge.annotations.ExtSyncAction;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ExtLoaderModule {

    @ExtActionJsImplement(assetsPath = "ext/loader/installModule.js")
    @ExtSyncAction("installModule")
    public Map<String, String> installModule(List<String> targets, Context context) {
        Map<String, String> map = new HashMap<>();
        if (targets != null && !targets.isEmpty()) {
            for (String target : targets) {
                Class<?> clz = ExtJSModuleFactory.getsInstance().moduleClass(target);
                String jsClass = ExtJSToolBox.getJSModuleClassCreator(clz, target, context);
                map.put(target, jsClass);
            }
        }
        return map;
    }

    @ExtActionJsImplement(assetsPath = "ext/loader/requireModule.js")
    @ExtSyncAction("requireModule")
    public Object requireModule(String name, IExtJSBridge bridge) {
        return bridge.saveModuleCache(name);
    }

}
