package com.pn_x.extjsbridge.annotations;

import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import static java.lang.annotation.ElementType.METHOD;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

@Target(METHOD)
@Retention(RUNTIME)
@ExtActionVerify(
        returnType = "java.lang.Object"
)
public @interface ExtAsyncAction {
    String value(); // action name
}
