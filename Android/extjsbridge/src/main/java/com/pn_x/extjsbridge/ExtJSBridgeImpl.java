package com.pn_x.extjsbridge;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import com.pn_x.extjsbridge.annotations.ExtAsyncAction;
import com.pn_x.extjsbridge.annotations.ExtSyncAction;
import com.pn_x.extjsbridge.module.ExtJSModule;

import java.lang.ref.WeakReference;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.text.ParseException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class ExtJSBridgeImpl {

    private static final String TAG = "ExtJSBridgeImpl";

    private WeakReference<IExtJSBridge> bridgeWrf;
    private WeakReference<Context> contextWrf;
    private Handler mainHandler;
    private HashMap<String, Object> moduleInstanceCache = new HashMap<>();

    public ExtJSBridgeImpl(Context context, IExtJSBridge bridge, Handler handler) {
        contextWrf = new WeakReference<>(context);
        bridgeWrf = new WeakReference<>(bridge);
        mainHandler = handler;
    }

    public String runMessage(String message) {
        try {
            final IExtJSBridge bridge = bridgeWrf.get();
            final Context context = contextWrf.get();
            if (context == null || bridge == null) {
                return replyError(message, new IllegalStateException("context or bridge is recycled unexpectedly"));
            }
            final ExtJSMessage jsMessage = new ExtJSMessage(message);
            jsMessage.setBridgeName(bridge.getBridgeName());

            if (bridge.getInterceptor() != null && bridge.getInterceptor().intercept(jsMessage)) {
                return replyError(jsMessage, new InterruptedException(
                        "intercepted by " + bridge.getInterceptor().getClass().getSimpleName()));
            }

            final Object value = jsMessage.getValue();

            Object targetInstance = getModuleCache(jsMessage.target);
            Object result = null;
            if (targetInstance != null) {
                result = executeInstanceAction(targetInstance, value, jsMessage, this);
            } else {
                result = executeAction(value, jsMessage, this);
            }
            return ExtJSToolBox.getSyncReplyResult(result);
        } catch (Exception e) {
            e.printStackTrace();
            return replyError(message, e);
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

    public Object executeAction(Object value, ExtJSMessage message, ExtJSBridgeImpl bridgeImpl)
            throws ClassNotFoundException, NoSuchMethodException, IllegalAccessException,
            InvocationTargetException, InstantiationException, ParseException {
        Class<?> targetClz = ExtJSModuleFactory.getsInstance().moduleClass(message.target);
        if (targetClz == null) {
            throw new ClassNotFoundException(TAG + " class for '" + message.target + "' not found");
        }
        Object targetInstance = null;
        if (ExtJSModule.class.isAssignableFrom(targetClz)) {
            Constructor<?> constructor = targetClz.getConstructor(String.class, Context.class, IExtJSBridge.class);
            targetInstance = constructor.newInstance(message.target, bridgeImpl.contextWrf.get(), bridgeImpl.bridgeWrf.get());
        } else {
            targetInstance = targetClz.newInstance();
        }
        return executeInstanceAction(targetInstance, value, message, bridgeImpl);
    }

    public Object executeInstanceAction(final Object instance, final Object value, final ExtJSMessage message, final ExtJSBridgeImpl bridgeImpl)
            throws ParseException, InvocationTargetException, IllegalAccessException {
        if (instance == null) {
            throw new NullPointerException(TAG + " executeInstanceAction instance is null");
        }
        Method[] methods = instance.getClass().getDeclaredMethods();
        for (final Method method : methods) {
            if (method.isAnnotationPresent(ExtSyncAction.class)) {
                ExtSyncAction syncAction = method.getAnnotation(ExtSyncAction.class);
                String[] actionNames = syncAction.value();
                if (Arrays.asList(actionNames).contains(message.action)) {
                    Object[] args = getMethodArgs(method, true, value, message, bridgeImpl);
                    if (args.length <= 0) {
                        return method.invoke(instance);
                    } else {
                        return method.invoke(instance, args);
                    }
                }
            } else if (method.isAnnotationPresent(ExtAsyncAction.class)) {
                ExtAsyncAction asyncAction = method.getAnnotation(ExtAsyncAction.class);
                String[] actionNames = asyncAction.value();
                if (Arrays.asList(actionNames).contains(message.action)) {
                    if (method.getReturnType() != Void.TYPE) {
                        Object[] args = getMethodArgs(method, false, value, message, bridgeImpl);
                        if (args.length <= 0) {
                            return method.invoke(instance);
                        } else {
                            return method.invoke(instance, args);
                        }
                    } else {
                        runOnMainThread(new Runnable() {
                            @Override
                            public void run() {
                                try {
                                    Object[] args = getMethodArgs(method, false, value, message, bridgeImpl);
                                    if (args.length <= 0) {
                                        method.invoke(instance);
                                    } else {
                                        method.invoke(instance, args);
                                    }
                                } catch (IllegalAccessException | IllegalArgumentException | InvocationTargetException | ParseException e) {
                                    e.printStackTrace();
                                    asyncReplyError(message, e);
                                }
                            }
                        });
                    }
                }
            }
        }
        return null;
    }

    public Object[] getMethodArgs(Method method, boolean isSync,
                                  Object value, ExtJSMessage message, ExtJSBridgeImpl bridgeImpl) throws ParseException {
        Class<?>[] types = method.getParameterTypes();
        if (types.length <= 0) {
            return new Object[0];
        } else {
            Object[] args = new Object[types.length];
            for (int i = 0; i < types.length; i++) {
                Class<?> type = types[i];
                args[i] = isSync ? getSyncMethodArg(type, value, message, bridgeImpl)
                        : getAsyncMethodArg(type, value, message, bridgeImpl);
            }
            return args;
        }
    }

    public Object getSyncMethodArg(Class<?> argClass, Object value, ExtJSMessage message, ExtJSBridgeImpl bridgeImpl) throws ParseException {
        if (ExtJSToolBox.isSupportedValueClass(argClass)) {
            return ExtJSToolBox.parseSupportedValue(value, argClass);
        } else if (argClass == ExtJSMessage.class) {
            return message;
        } else if (argClass == Context.class || Context.class.isAssignableFrom(argClass)) {
            return bridgeImpl.contextWrf.get();
        } else if (argClass == IExtJSBridge.class || IExtJSBridge.class.isAssignableFrom(argClass)) {
            return bridgeImpl.bridgeWrf.get();
        }
        throw new IllegalArgumentException("Unsupported arg class type: " + argClass.getSimpleName());
    }

    public Object getAsyncMethodArg(Class<?> argClass, Object value, ExtJSMessage message, ExtJSBridgeImpl bridgeImpl) throws ParseException {
        if (argClass == ExtJSAsyncReply.class || argClass.isAssignableFrom(ExtJSAsyncReply.class)) {
            return new ExtJSAsyncReply(message, bridgeImpl.bridgeWrf.get());
        } else {
            return getSyncMethodArg(argClass, value, message, bridgeImpl);
        }
    }

    public String replyError(String message, Exception e) {
        ExtJSMessage jsMessage = new ExtJSMessage(message);
        return replyError(jsMessage, e);
    }

    public String replyError(ExtJSMessage message, Exception e) {
        asyncReplyError(message, e);
        return ExtJSToolBox.getSyncReplyResult(
                ExtJSToolBox.getJSError(
                        e.getClass().getSimpleName(),
                        e.getMessage()));
    }

    public void asyncReplyError(ExtJSMessage message, Exception e) {
        new ExtJSAsyncReply(message, this.bridgeWrf.get()).fail(e);
    }

    public void saveModuleCache(String target, Object instance) {
        moduleInstanceCache.put(target, instance);
    }

    public boolean saveModuleCache(String target) {
        Class<?> clz = ExtJSModuleFactory.getsInstance().moduleClass(target);
        Object instance = null;
        if (clz != null) {
            try {
                if (ExtJSModule.class.isAssignableFrom(clz)) {
                    Constructor<?> constructor = clz.getConstructor(String.class, Context.class, IExtJSBridge.class);
                    if (constructor != null) {
                        instance = constructor.newInstance(target, contextWrf.get(), bridgeWrf.get());
                    }
                } else {
                    instance = clz.newInstance();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        if (instance != null) {
            moduleInstanceCache.put(target, instance);
            return true;
        } else {
            return false;
        }
    }

    public Object getModuleCache(String target) {
        return moduleInstanceCache.get(target);
    }

    public boolean deleteModuleCache(String target) {
        return moduleInstanceCache.remove(target) == null;
    }

    public Map<String, Object> getModuleCache() {
        return moduleInstanceCache;
    }

    public IExtJSBridge getBridge() {
        return bridgeWrf.get();
    }
}
