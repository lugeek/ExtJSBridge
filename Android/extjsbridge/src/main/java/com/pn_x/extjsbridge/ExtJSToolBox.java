package com.pn_x.extjsbridge;

import com.pn_x.extjsbridge.annotations.ExtAsyncAction;
import com.pn_x.extjsbridge.annotations.ExtSyncAction;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.lang.reflect.Method;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.text.NumberFormat;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ExtJSToolBox {

    public static final String ExtJSValueTypeString = "S";
    public static final String ExtJSValueTypeNumber = "N";
    public static final String ExtJSValueTypeBool = "B";
    public static final String ExtJSValueTypeObject = "O";
    public static final String ExtJSValueTypeArray = "A";
    public static final String ExtJSValueTypeError = "E";

    public static final String ExtJSCallbackFunctionSuccess = "_s";
    public static final String ExtJSCallbackFunctionFail = "_f";
    public static final String ExtJSCallbackFunctionProgress = "_p";

    private ExtJSToolBox() {
    }

    public static String convertNativeValue(Object value) {
        Object wrapValue = JSONUtil.wrap(value);
        String type = "";
        String valueStr = "";
        if (wrapValue == null || wrapValue == JSONObject.NULL) {
            type = ExtJSValueTypeString;
            valueStr = "";
        } else if (wrapValue instanceof ExtJSError) {
            type = ExtJSValueTypeError;
            valueStr = ((JSONObject)wrapValue).toString();
        } else if (wrapValue instanceof JSONArray) {
            type = ExtJSValueTypeArray;
            valueStr = ((JSONArray) wrapValue).toString();
        } else if (wrapValue instanceof JSONObject) {
            type = ExtJSValueTypeObject;
            valueStr = ((JSONObject) wrapValue).toString();
        } else if (wrapValue instanceof Boolean) {
            type = ExtJSValueTypeBool;
            valueStr = String.valueOf((Boolean) wrapValue);
        } else if (wrapValue instanceof Byte ||
                wrapValue instanceof Double ||
                wrapValue instanceof Float ||
                wrapValue instanceof Integer ||
                wrapValue instanceof Long ||
                wrapValue instanceof Short) {
            type = ExtJSValueTypeNumber;
            valueStr = String.valueOf((Number)wrapValue);
        } else {
            type = ExtJSValueTypeString;
            try {
                valueStr = URLEncoder.encode(String.valueOf(wrapValue), "UTF-8");
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
                type = ExtJSValueTypeError;
                valueStr = getJSError(e).toString();
            }
        }
        return String.format("%s/%s", type, valueStr);
    }

    public static String getSyncReplyResult(Object result) {
        return ExtJSToolBox.convertNativeValue(result);
    }

    public static String getAsyncReplyJS(String bridgeName, ExtJSMessage message, Object result, String fun) {
        return String.format("%s.%s('%s/%s/%s/%s')",
                bridgeName,
                fun,
                message.target,
                message.action,
                message.messageId,
                ExtJSToolBox.convertNativeValue(result));
    }

    public static String getAsyncReplyFailJS(String bridgeName, ExtJSMessage message, Object result) {
        return getAsyncReplyJS(bridgeName, message, result, ExtJSCallbackFunctionFail);
    }

    public static String getAsyncReplySuccessJS(String bridgeName, ExtJSMessage message, Object result) {
        return getAsyncReplyJS(bridgeName, message, result, ExtJSCallbackFunctionSuccess);
    }

    public static String getAsyncProgressReplyResult(String bridgeName, ExtJSMessage message, Object result) {
        return getAsyncReplyJS(bridgeName, message, result, ExtJSCallbackFunctionProgress);
    }

    public static String getPostMessageJS(String bridgeName, String target, String message, Object value) {
        return String.format("%s._mim.get(\"%s\").channel.post(\"%s\", \"%s\")",
                bridgeName,
                target,
                message,
                ExtJSToolBox.convertNativeValue(value));
    }

    public static Object getNativeValue(String valueType, String value) throws UnsupportedEncodingException, JSONException, ParseException {
        String decodeString = value != null ? URLDecoder.decode(value, "UTF-8") : "";
        if (ExtJSValueTypeString.equals(valueType)) {
            return decodeString;
        } else if (ExtJSValueTypeNumber.equals(valueType)) {
            NumberFormat nf = NumberFormat.getInstance();
            return nf.parse(decodeString);
        } else if (ExtJSValueTypeBool.equals(valueType)) {
            return Boolean.parseBoolean(decodeString);
        } else if (ExtJSValueTypeObject.equals(valueType)) {
            return JSONUtil.unwrap(new JSONObject(decodeString));
        } else if (ExtJSValueTypeArray.equals(valueType)) {
            return JSONUtil.unwrap(new JSONArray(decodeString));
        } else if (ExtJSValueTypeError.equals(valueType)) {
            return new ExtJSError(decodeString);
        } else {
            return decodeString;
        }
    }

    public static boolean isSupportedValueClass(Class<?> clz) {
        return clz == String.class
                || clz == Map.class
                || clz == HashMap.class
                || clz == List.class
                || clz == ArrayList.class
                || clz == Boolean.class
                || clz == Boolean.TYPE // boolean
                || clz == ExtJSError.class
                || Number.class.isAssignableFrom(clz) // Integer || Long || Float || Double || Short || Byte
                || clz == Integer.TYPE // int
                || clz == Long.TYPE  // long
                || clz == Float.TYPE  // float
                || clz == Double.TYPE // double
                || clz == Short.TYPE // short
                || clz == Byte.TYPE; // byte
    }

    public static Object parseSupportedValue(Object value, Class<?> wanted) throws ParseException {
        if (value instanceof String && wanted == String.class) {
            return value;
        } else if (value instanceof HashMap && (wanted == Map.class || wanted == HashMap.class)) {
            return value;
        } else if (value instanceof ArrayList && (wanted == List.class || wanted == ArrayList.class)) {
            return value;
        } else if (value instanceof Boolean && (wanted == Boolean.class || wanted == Boolean.TYPE)) {
            return value;
        } else if (value instanceof ExtJSError && (wanted == ExtJSError.class)) {
            return value;
        } else if (value instanceof Number) {
            if (wanted == Integer.class || wanted == Integer.TYPE) {
                return ((Number) value).intValue();
            } else if (wanted == Long.class || wanted == Long.TYPE) {
                return ((Number) value).longValue();
            } else if (wanted == Float.class || wanted == Float.TYPE) {
                return ((Number) value).floatValue();
            } else if (wanted == Double.class || wanted == Double.TYPE) {
                return ((Number) value).doubleValue();
            } else if (wanted == Short.class || wanted == Short.TYPE) {
                return ((Number) value).shortValue();
            } else if (wanted == Byte.class || wanted == Byte.TYPE) {
                return ((Number) value).byteValue();
            }
        } else {
            throw new ParseException("ExtJSBridge parseSupportedValue error: " + wanted.getSimpleName() + " is wanted, but value is " + value.getClass().getSimpleName(), 0);
        }
        return null;
    }

    public static String getJSModuleClassCreator(Class<?> clz, String target) {
        Method[] methods = clz.getDeclaredMethods();
        StringBuilder funcs = new StringBuilder();
        for (final Method method : methods) {
            if (method.isAnnotationPresent(ExtAsyncAction.class)) {
                ExtAsyncAction asyncAction = method.getAnnotation(ExtAsyncAction.class);
                String actions[] = asyncAction.value();
                for (String action : actions) {
                    funcs.append(String.format("%s(arg){return ext._i(\"%s\",\"%s\",arg,%s)}",
                            action, target, action, "false"));
                }
            } else if (method.isAnnotationPresent(ExtSyncAction.class)) {
                ExtSyncAction syncAction = method.getAnnotation(ExtSyncAction.class);
                String actions[] = syncAction.value();
                for (String action : actions) {
                    funcs.append(String.format("%s(arg){return ext._i(\"%s\",\"%s\",arg,%s)}",
                            action, target, action, "true"));
                }
            }
        }
        return String.format("class _ {%s}", funcs.toString());
    }

    public static ExtJSError getJSError(Exception e) {
        if (e == null) return null;
        return getJSError(e.getClass().getName(), e.getMessage());
    }

    public static ExtJSError getJSError(String name, String message) {
        return getJSError(name, message, -1);
    }

    public static ExtJSError getJSError(String name, String message, int code) {
        return new ExtJSError(name == null ? "" : name, message == null ? "" : message, code);
    }

}
