package com.pn_x.extjsbridge.annotations;

import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import static java.lang.annotation.ElementType.METHOD;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

@Target(METHOD)
@Retention(RUNTIME)
public @interface ExtActionJsImplement {
    String value() default ""; // javascript string
    String assetsPath() default ""; // javascript file full name in assets
}
