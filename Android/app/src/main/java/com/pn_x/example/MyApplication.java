package com.pn_x.example;

import android.app.Application;
import android.webkit.WebView;

import com.facebook.stetho.Stetho;
import com.pn_x.example.module.AlertModule;
import com.pn_x.example.module.EnvModule;
import com.pn_x.example.module.NavigatorModule;
import com.pn_x.example.module.TimerModule;
import com.pn_x.example.module.ValueTestModule;
import com.pn_x.extjsbridge.ExtJSModuleFactory;

public class MyApplication extends Application {
  public void onCreate() {
    super.onCreate();
    WebView.setWebContentsDebuggingEnabled(true);
    Stetho.initializeWithDefaults(this); // chrome://inspect/#devices
    ExtJSModuleFactory.getsInstance().registerModuleClass("alert", AlertModule.class);
    ExtJSModuleFactory.getsInstance().registerModuleClass("env", EnvModule.class);
    ExtJSModuleFactory.getsInstance().registerModuleClass("navigator", NavigatorModule.class);
    ExtJSModuleFactory.getsInstance().registerModuleClass("timer", TimerModule.class);
    ExtJSModuleFactory.getsInstance().registerModuleClass("valueTest", ValueTestModule.class);
//    ECMapper.init(this);
//    ExtJSModuleFactory.getsInstance().registerModelClass(ECMapper.targetsIndex);
  }
}