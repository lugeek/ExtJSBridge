package com.pn_x.extjsbridge;

import java.lang.ref.WeakReference;

public class ExtJSAsyncReply {

    public ExtJSMessage message;
    public WeakReference<IExtJSBridge> bridgeWrf;
    public boolean hasReplied;

    public ExtJSAsyncReply(ExtJSMessage message, IExtJSBridge bridge) {
        this.message = message;
        this.bridgeWrf = new WeakReference<>(bridge);
    }

    public void reply(Object result) {
        IExtJSBridge bridge = bridgeWrf.get();
        if (bridge != null) {
            bridge.jsRun(ExtJSToolBox.getAsyncReplySuccessJS(bridge.getBridgeName(), message, result));
        }
        hasReplied = true;
    }

    public void fail(String msg) {
        IExtJSBridge bridge = bridgeWrf.get();
        if (bridge != null) {
            bridge.jsRun(ExtJSToolBox.getAsyncReplyFailJS(bridge.getBridgeName(), message, ExtJSToolBox.getJSError("error", msg)));
        }
        hasReplied = true;
    }

    public void fail(Exception e) {
        IExtJSBridge bridge = bridgeWrf.get();
        if (bridge != null) {
            bridge.jsRun(ExtJSToolBox.getAsyncReplyFailJS(bridge.getBridgeName(), message, ExtJSToolBox.getJSError(e)));
        }
        hasReplied = true;
    }

    public void progress(Object result) {
        IExtJSBridge bridge = bridgeWrf.get();
        if (bridge != null) {
            bridge.jsRun(ExtJSToolBox.getAsyncProgressReplyResult(bridge.getBridgeName(), message, result));
        }
    }

    @Override
    protected void finalize() throws Throwable {
        if (!hasReplied)
            this.fail("reply for message(id=" + message.messageId + ") is recycled");
        super.finalize();
    }
}
