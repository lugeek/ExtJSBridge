package com.pn_x.extjsbridge;

import android.content.Context;

import com.pn_x.extjsbridge.ExtJSToolBox;
import com.pn_x.extjsbridge.IExtJSBridge;

import java.lang.ref.WeakReference;

public abstract class ExtJSModule {

    protected String target;
    protected WeakReference<IExtJSBridge> bridgeWrf;

    public ExtJSModule(String target, Context context, IExtJSBridge bridge) {
        this.target = target;
        this.bridgeWrf = new WeakReference<>(bridge);
    }

    protected void postMessage(String message, Object value) {
        if (message == null || message.isEmpty()) {
            return;
        }
        IExtJSBridge bridge = bridgeWrf.get();
        if (bridge == null) {
            return;
        }
        final String script = ExtJSToolBox.getPostMessageJS(bridge.getBridgeName(), target, message, value);
        bridge.jsRun(script);
    }

    public void release() {
        // will be called while bridge is released.
    }

    public void onPageStarted(String oldUrl, String newUrl) {
        // will be called while current webview page changed.
    }
}
