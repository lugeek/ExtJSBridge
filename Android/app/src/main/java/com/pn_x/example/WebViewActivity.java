package com.pn_x.example;

import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.pn_x.extjsbridge.ExtJSWebBridge;

public class WebViewActivity extends AppCompatActivity {

  private WebView mWebView;
  private ExtJSWebBridge bridge;

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_webview);
    mWebView = findViewById(R.id.webview);

    WebSettings setting = mWebView.getSettings();
    setting.setBuiltInZoomControls(false);
    setting.setSupportZoom(false);
    setting.setAllowFileAccess(false);
    setting.setJavaScriptCanOpenWindowsAutomatically(true);
    setting.setJavaScriptEnabled(true);
    setting.setDatabaseEnabled(true);
    setting.setDomStorageEnabled(true);

    mWebView.setWebChromeClient(new WebChromeClient());
    mWebView.setWebViewClient(new WebViewClient(){
      @Override
      public void onPageStarted(WebView view, String url, Bitmap favicon) {
        super.onPageStarted(view, url, favicon);
        bridge.onPageStarted(view, url, favicon); // check url change
      }
    });

    bridge = new ExtJSWebBridge.Builder(this, mWebView)
            .interceptor(message -> { // return true for intercepting.
              if (message.target.startsWith("#")) {
                return true;
              }
              return false;
            })
            .build();

    mWebView.loadUrl("file:///android_asset/sample/index.html");
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    bridge.release(true);
  }
}
