package com.pn_x.example.module;

import android.content.Context;
import android.os.CountDownTimer;
import android.os.Handler;
import android.os.Looper;
import android.util.SparseArray;

import com.pn_x.extjsbridge.ExtJSAsyncReply;
import com.pn_x.extjsbridge.IExtJSBridge;
import com.pn_x.extjsbridge.annotations.ExtAsyncAction;
import com.pn_x.extjsbridge.annotations.ExtSyncAction;
import com.pn_x.extjsbridge.ExtJSModule;

import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public class TimerModule extends ExtJSModule {

  private SparseArray<CountDownTimer> timers;
  private AtomicInteger index;

  public TimerModule(String target, Context context, IExtJSBridge bridge) {
    super(target, context, bridge);
    timers = new SparseArray<>();
    index = new AtomicInteger(0);
  }

  @ExtAsyncAction("setTimeout")
  public void setTimeout(Map<String, Integer> data, final ExtJSAsyncReply reply) {
    Integer time = data.get("millseconds");
    if (time == null) return;
    new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
      @Override
      public void run() {
        reply.reply(true);
      }
    }, time);
  }

  @ExtAsyncAction("setInterval")
  public int setInterval(Map<String, Integer> data, final ExtJSAsyncReply reply) {
    Integer time = data.get("millseconds");
    if (time == null) return -1;
    CountDownTimer timer = new CountDownTimer(5 * 60 * 1000, time) {
      @Override
      public void onTick(long millisUntilFinished) {
        reply.progress(millisUntilFinished / 1000);
      }

      @Override
      public void onFinish() {

      }
    };
    int curIndex = index.getAndIncrement();
    timers.append(curIndex, timer);
    timer.start();
    return curIndex;
  }

  @ExtSyncAction("clearInterval")
  public void clearInterval(int index) {
    CountDownTimer timer = timers.get(index);
    timer.cancel();
    timers.remove(index);
  }

}
