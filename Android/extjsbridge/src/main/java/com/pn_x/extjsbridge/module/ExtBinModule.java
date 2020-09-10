package com.pn_x.extjsbridge.module;

import com.pn_x.extjsbridge.ExtJSModuleFactory;
import com.pn_x.extjsbridge.ExtJSToolBox;
import com.pn_x.extjsbridge.IExtJSBridge;
import com.pn_x.extjsbridge.annotations.ExtSyncAction;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ExtBinModule {

    @ExtSyncAction("installModule")
    public Map installModule(List<String> targets) {
        Map<String, String> map = new HashMap<>();
        if (targets != null && !targets.isEmpty()) {
            for (String target : targets) {
                Class<?> clz = ExtJSModuleFactory.getsInstance().moduleClass(target);
                String jsClass = ExtJSToolBox.getJSModuleClassCreator(clz, target);
                map.put(target, jsClass);
            }
        }
        return map;
    }

    @ExtSyncAction("requireModule")
    public Object requireModule(String name, IExtJSBridge bridge) {
        return bridge.saveModuleCache(name);
    }
}
