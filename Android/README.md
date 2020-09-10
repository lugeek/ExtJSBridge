Configuration
--------
1. dependencies 
```groovy
dependencies {
  implementation 'com.github.pn-x:extjsbridge:0.0.3'
  annotationProcessor 'com.github.pn-x:extjsbridge-compiler:0.0.3'
}
```

2. Init
```java
  // register moduler in Application onCreate
  ExtJSModuleFactory.getsInstance().registerModuleClass("xxx", xxx.class);
  
  // or use ExtClassMapper(https://github.com/lugeek/ExtClassMapper) to register modules by annotations.
  ECMapper.init(this);
  ExtJSModuleFactory.getsInstance().registerModelClass(ECMapper.targetsIndex);
  
  // init bridge
  bridge = new ExtJSWebBridge.Builder(this, mWebView)
  .interceptor(message -> { // return true for intercepting.
    if (message.target.startsWith("#")) {
      return true;
    }
    return false;
  })
  .build();
  
  // webview onPageStart 
  mWebView.setWebViewClient(new WebViewClient(){
    @Override
    public void onPageStarted(WebView view, String url, Bitmap favicon) {
      super.onPageStarted(view, url, favicon);
      bridge.onPageStarted(view, url, favicon); // check page change
    }
  });

  // release
  @Override
  protected void onDestroy() {
      super.onDestroy();
      bridge.release(true);
  }
```

3. Module

```java
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
```

4. proguard-rules
```
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
```
or  
```
-keep class android.support.annotation.Keep
```
