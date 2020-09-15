package com.pn_x.example.module;

import android.arch.lifecycle.Lifecycle;
import android.arch.lifecycle.LifecycleObserver;
import android.arch.lifecycle.OnLifecycleEvent;
import android.content.Context;
import android.content.Intent;

import com.pn_x.example.WebViewActivity;
import com.pn_x.extjsbridge.IExtJSBridge;
import com.pn_x.extjsbridge.annotations.ExtSyncAction;
import com.pn_x.extjsbridge.ExtJSModule;

import java.lang.ref.WeakReference;

public class NavigatorModule extends ExtJSModule {

  private LifecycleObserver lifecycleObserver;
  private WeakReference<Context> contextWrf;

  public NavigatorModule(String target, Context context, IExtJSBridge bridge) {
    super(target, context, bridge);
    contextWrf = new WeakReference<>(context);
    lifecycleObserver = new LifecycleObserver() {
      @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
      public void onResume() {
        NavigatorModule.this.postMessage("onPageAppear", null);
      }
    };
    if (context instanceof WebViewActivity) {
      ((WebViewActivity) context).getLifecycle().addObserver(lifecycleObserver);
    }
  }

  @ExtSyncAction("open")
  public boolean open(String arg, Context context) {
    Class<?> activity = WebViewActivity.class;
    if (arg != null && arg.equals("webview")) {
      activity = WebViewActivity.class;
    }
    Intent intent = new Intent(context, activity);
    context.startActivity(intent);
    return true;
  }

  @ExtSyncAction("close")
  public boolean close(WebViewActivity activity) {
    activity.finish();
    return true;
  }

  @ExtSyncAction("setTitle")
  public boolean setTitle(String title, WebViewActivity activity) {
    activity.getSupportActionBar().setTitle(title);
    return true;
  }

  @Override
  public void release() {
    Context context = contextWrf.get();
    if (context instanceof WebViewActivity) {
      ((WebViewActivity) context).getLifecycle().removeObserver(lifecycleObserver);
    }
  }
}
