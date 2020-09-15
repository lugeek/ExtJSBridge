package com.pn_x.extjsbridge;

import org.json.JSONException;
import org.json.JSONObject;

public class ExtJSError extends JSONObject {

    public ExtJSError(String name, String msg, int code) {
        super();
        try {
            put("n", name);
            put("m", msg);
            put("c", code);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public ExtJSError(String json) throws JSONException {
        super(json);
    }
}