package com.pn_x.example.module;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Handler;
import android.os.Looper;
import android.os.MessageQueue;
import android.view.ViewTreeObserver;

import com.pn_x.extjsbridge.annotations.ExtAsyncAction;

import java.util.Map;

public class AlertModule {

  @ExtAsyncAction({"show"})
  public void showAlert(Map<String, String> map, Context context) {
    if (context == null) {
      return;
    }
    try {
      DetachableClickListener listener = DetachableClickListener.wrap(new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialog, int which) {
          dialog.dismiss();
        }
      });
      AlertDialog dialog = new AlertDialog.Builder(context)
              .setTitle(map.get("title"))
              .setMessage(map.get("message"))
              .setPositiveButton("OK", listener)
              .create();
      listener.clearOnDetach(dialog);
      dialog.show();
    } catch (Exception e) {
      e.printStackTrace();
    }
    return;
  }

  // loop阻塞 -> msg -> OnClickListener -> AlertExecutor 造成泄漏，包装一层解决
  public static final class DetachableClickListener implements DialogInterface.OnClickListener {

    public static DetachableClickListener wrap(DialogInterface.OnClickListener delegate) {
      return new DetachableClickListener(delegate);
    }

    private DialogInterface.OnClickListener delegateOrNull;

    private DetachableClickListener(DialogInterface.OnClickListener delegate) {
      this.delegateOrNull = delegate;
    }

    @Override
    public void onClick(DialogInterface dialog, int which) {
      if (delegateOrNull != null) {
        delegateOrNull.onClick(dialog, which);
      }
    }

    public void clearOnDetach(Dialog dialog) {
      dialog.getWindow()
              .getDecorView()
              .getViewTreeObserver()
              .addOnWindowAttachListener(new ViewTreeObserver.OnWindowAttachListener() {
                @Override
                public void onWindowAttached() {
                }

                @Override
                public void onWindowDetached() {
                  delegateOrNull = null;
                }
              });
    }
  }

  // 在一个常用的基础清晰你的工作者线程：当 Handler 闲置就向它发送空 Message，以确保不会发生 Message 的内存泄漏。
  public static void flushStackLocalLeaks(Looper looper) {
    final Handler handler = new Handler(looper);
    handler.post(new Runnable() {
      @Override
      public void run() {
        Looper.myQueue().addIdleHandler(new MessageQueue.IdleHandler() {
          @Override
          public boolean queueIdle() {
            handler.sendMessageDelayed(handler.obtainMessage(), 1000);
            return true;
          }
        });
      }
    });
  }
}
