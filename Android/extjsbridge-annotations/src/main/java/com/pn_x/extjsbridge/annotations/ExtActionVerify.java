package com.pn_x.extjsbridge.annotations;

import java.lang.annotation.Retention;
import java.lang.annotation.Target;

import static java.lang.annotation.ElementType.ANNOTATION_TYPE;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

@Retention(RUNTIME)
@Target(ANNOTATION_TYPE)
public @interface ExtActionVerify {
    String[] parameters() default { };

    /** Primitive or fully-qualified return type of the listener method. May also be {@code void}. */
    String returnType() default "void";
}
