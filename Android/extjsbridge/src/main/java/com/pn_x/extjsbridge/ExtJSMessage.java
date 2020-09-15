package com.pn_x.extjsbridge;

import android.text.TextUtils;

import org.json.JSONException;

import java.io.UnsupportedEncodingException;
import java.text.ParseException;

public class ExtJSMessage {

    public String target;

    public String action;

    public String messageId;

    public String valueType;

    public String value;

    public String bridgeName;

    // message: target/action/messageId/valueType/value
    public ExtJSMessage(String rawString) {
        String[] array = rawString.split("/");
        if (array.length > 0) {
            this.target = array[0];
            if (TextUtils.isEmpty(this.target)) {
                throw new IllegalArgumentException("[ExtJSBridge]Invalid target");
            }
        }
        if (array.length > 1) {
            this.action = array[1];
            if (TextUtils.isEmpty(this.action)) {
                throw new IllegalArgumentException("[ExtJSBridge]Invalid action");
            }
        }
        if (array.length > 2) {
            this.messageId = array[2];
            if (TextUtils.isEmpty(this.messageId)) {
                throw new IllegalArgumentException("[ExtJSBridge]Invalid id");
            }
        }
        if (array.length > 3) {
            this.valueType = array[3];
        }
        if (array.length > 4) {
            this.value = array[4];
        }
    }

    public Object getValue() throws UnsupportedEncodingException, JSONException, ParseException {
        return ExtJSToolBox.getNativeValue(valueType, value);
    }

    public void setBridgeName(String name) {
        this.bridgeName = name;
    }
}
