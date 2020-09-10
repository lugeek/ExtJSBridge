package com.pn_x.extjsbridge;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

public interface IExtJSBridge {

    @NonNull String getBridgeName();
    String getUniqueURI();
    void setUniqueURI(String uri);
    void jsRun(String script);
    @Nullable IExtModuleInterceptor getInterceptor();
    void setInterceptor(@Nullable IExtModuleInterceptor security);
    boolean saveModuleCache(String target);
    Object getModuleCache(String target);
    boolean deleteModuleCache(String target);
}
