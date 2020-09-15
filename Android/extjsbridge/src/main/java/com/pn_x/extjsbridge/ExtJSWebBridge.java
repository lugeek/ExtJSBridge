package com.pn_x.extjsbridge;

import android.content.Context;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.Keep;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.View;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.ref.WeakReference;

public class ExtJSWebBridge implements IExtJSBridge {

    protected WeakReference<WebView> webViewWrf;
    protected ExtJSBridgeImpl bridgeImpl;
    protected IExtModuleInterceptor interceptor;
    protected String compactUrl;
    protected Handler mainHandler = new Handler(Looper.getMainLooper());

    public ExtJSWebBridge(Context context, WebView webView) {
        this.webViewWrf = new WeakReference<>(webView);
        this.bridgeImpl = new ExtJSBridgeImpl(context, this, mainHandler);
    }

    @Keep
    @JavascriptInterface
    public String prompt(String bridgeName, String message) {
        if (bridgeName == null || bridgeName.isEmpty() || !bridgeName.equals(getBridgeName())) {
            return "";
        }
        return bridgeImpl.runMessage(message);
    }

    protected void evaluateJavaScript(String script) {
        WebView webView = webViewWrf.get();
        if (webView == null) return;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            webView.evaluateJavascript(script, null);
        } else {
            webView.loadUrl("javascript:" + script);
        }
    }

    @Override
    public @NonNull String getBridgeName() {
        return "ext";
    }

    @Override
    public String getUniqueURI() {
        return compactUrl != null ? compactUrl : "";
    }

    @Override
    public void setUniqueURI(String url) {
        if (url != null) {
            Uri uri = Uri.parse(url);
            String newCompatUrl = uri.getScheme() + "://" + uri.getHost() + uri.getPath();
            if (!newCompatUrl.equals(this.compactUrl)) {
                this.compactUrl = newCompatUrl;
            }
        }
    }

    @Override
    public void jsRun(final String script) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                evaluateJavaScript(script);
            }
        });
    }

    @Override
    public @Nullable IExtModuleInterceptor getInterceptor() {
        return interceptor;
    }

    @Override
    public void setInterceptor(@Nullable IExtModuleInterceptor security) {
        this.interceptor = security;
    }

    @Override
    public boolean saveModuleCache(String target) {
        return bridgeImpl.saveModuleCache(target);
    }

    @Override
    public Object getModuleCache(String target) {
        return bridgeImpl.getModuleCache(target);
    }

    @Override
    public boolean deleteModuleCache(String target) {
        return bridgeImpl.deleteModuleCache(target);
    }

    public void onPageStarted(WebView view, String url, Bitmap favicon) {
        String oldUrl = compactUrl;
        setUniqueURI(url);
        String newUrl = compactUrl;
        if (bridgeImpl != null && newUrl != null && !newUrl.equals(oldUrl)) {
            for (String key : bridgeImpl.getModuleCache().keySet()) {
                Object instance = bridgeImpl.getModuleCache().get(key);
                if (instance instanceof ExtJSModule) {
                    ((ExtJSModule) instance).onPageStarted(oldUrl, newUrl);
                }
            }
        }
    }

    public void runOnMainThread(Runnable runnable) {
        if (Looper.getMainLooper() == Looper.myLooper()) {
            // 主线程
            runnable.run();
            return;
        }
        mainHandler.post(runnable);
    }

    public void release(boolean destroyWebView) {
        WebView webView = webViewWrf.get();
        if (webView != null) {
            webView.removeJavascriptInterface(getBridgeName());
            if (destroyWebView) {
                webView.setWebChromeClient(null);
                webView.setWebViewClient(null);
                webView.stopLoading();
                webView.setVisibility(View.GONE);
                webView.loadUrl("about:blank");
                webView.destroy();
                webView = null;
            }
        }
        if (mainHandler != null) {
            mainHandler.removeCallbacksAndMessages(null);
        }
        if (bridgeImpl != null) {
            for (String key : bridgeImpl.getModuleCache().keySet()) {
                Object instance = bridgeImpl.getModuleCache().get(key);
                if (instance instanceof ExtJSModule) {
                    ((ExtJSModule) instance).release();
                }
            }
        }
    }

    public static class Builder {
        private Context context;
        private WebView webView;
        private IExtModuleInterceptor interceptor;
        public Builder(Context context, WebView webView) {
            this.context = context;
            this.webView = webView;
        }

        public Builder interceptor(IExtModuleInterceptor interceptor) {
            this.interceptor = interceptor;
            return this;
        }

        public ExtJSWebBridge build() {
            ExtJSWebBridge bridge = new ExtJSWebBridge(context, webView);
            bridge.setInterceptor(interceptor);
            webView.addJavascriptInterface(bridge, bridge.getBridgeName());
            return bridge;
        }

        protected String preLoadInternalScript(String assetName) {
            StringBuilder jscontent = new StringBuilder();
            InputStream is = null;
            try{
                is = context.getAssets().open(assetName);
                InputStreamReader isr = new InputStreamReader(is);
                BufferedReader br = new BufferedReader(isr);

                String line;
                while ((line = br.readLine()) != null) {
                    jscontent.append(line);
                }
            } catch(Exception e){
                e.printStackTrace();
            } finally {
                if (is != null) {
                    try {
                        is.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
            return jscontent.toString();
        }

    }
}
