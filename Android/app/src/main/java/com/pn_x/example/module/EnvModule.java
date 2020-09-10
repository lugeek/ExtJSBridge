package com.pn_x.example.module;

import android.content.Context;
import android.os.CountDownTimer;

import com.pn_x.extjsbridge.ExtJSAsyncReply;
import com.pn_x.extjsbridge.IExtJSBridge;
import com.pn_x.extjsbridge.annotations.ExtAsyncAction;
import com.pn_x.extjsbridge.annotations.ExtSyncAction;
import com.pn_x.extjsbridge.module.ExtJSModule;

/**
 * Extends ExtJSModule is optional, it adds three features:
 * 1. 'postMessage': pass message to javascript;
 * 2. 'release': do something to release;
 * 3. 'onPageStarted': do something when page changed;
 */
public class EnvModule extends ExtJSModule {
  private CountDownTimer timer;

  public EnvModule(String target, Context context, IExtJSBridge bridge) {
    super(target, context, bridge);
    if (timer == null) {
      timer = new CountDownTimer(60 * 1000, 1000) {
        @Override
        public void onTick(long millisUntilFinished) {
          EnvModule.this.postMessage("StateChange", "count:" + millisUntilFinished / 1000);
        }

        @Override
        public void onFinish() {
          EnvModule.this.postMessage("StateChange", "finish");
        }
      };
    }
    timer.cancel();
    timer.start();
  }

  /**
   * Sync Action: return value immediately in JavaBridge work thread.
   * The annotation method support 4 kind of parameters, everyone is optional, order is arbitrary:
   * 1. Object: the value passed from JavaScript, it has been resolved to native type, choose you want:
   *    - String
   *    - Integer(int)
   *    - Long(long)
   *    - Float(float)
   *    - Double(double)
   *    - Short(short)
   *    - Byte(byte)
   *    - Boolean(boolean)
   *    - Map<String, Object>
   *    - List<Object>
   *    - ExtJSError
   * 2. ExtJSMessage: the message object from JavaScript;
   * 3. Context: the webview context;
   * 4. IExtJSBridge: the bridge;
   */
  @ExtSyncAction("platformSync")
  public String platformSync(Context context) {
    return "Android";
  }

  /**
   * Async Action: callback value by reply in main thread.
   * Same parameters as Sync Action, add one more parameter support:
   * ExtJSAsyncReply: reply for async action;
   */
  @ExtAsyncAction("platform")
  public void platform(ExtJSAsyncReply reply) {
    reply.reply("Android");
  }

  @Override
  public void release() {
    timer.cancel();
    timer = null;
  }
}
