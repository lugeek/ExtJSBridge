package com.pn_x.example.module;

import com.pn_x.extjsbridge.ExtJSError;
import com.pn_x.extjsbridge.annotations.ExtSyncAction;

import java.util.HashMap;
import java.util.Map;

public class ValueTestModule {

  @ExtSyncAction("intf")
  public String intf(int num) {
    return num + "";
  }

  @ExtSyncAction("intF")
  public String intF(Integer num) {
    return num + "";
  }

  @ExtSyncAction("longf")
  public String longf(long num) {
    return num + "";
  }

  @ExtSyncAction("longF")
  public String longF(Long num) {
    return num + "";
  }

  @ExtSyncAction("floatf")
  public String floatf(float num) {
    return num + "";
  }

  @ExtSyncAction("floatF")
  public String floatF(Float num) {
    return num + "";
  }

  @ExtSyncAction("doublef")
  public String doublef(double num) {
    return num + "";
  }

  @ExtSyncAction("doubleF")
  public String doubleF(Double num) {
    return num + "";
  }

  @ExtSyncAction("shortf")
  public String shortf(short num) {
    return num + "";
  }

  @ExtSyncAction("shortF")
  public String shortF(Short num) {
    return num + "";
  }

  @ExtSyncAction("bytef")
  public String bytef(byte num) {
    return num + "";
  }

  @ExtSyncAction("byteF")
  public String byteF(Byte num) {
    return num + "";
  }

  @ExtSyncAction("mapF")
  public String mapF(Map num) {
    return num.toString();
  }

  @ExtSyncAction("hashmapF")
  public String hashmapF(HashMap num) {
    return num.toString();
  }

  @ExtSyncAction("errorF")
  public String errorF(ExtJSError error) {
    return error.toString();
  }

  @ExtSyncAction("booleanf")
  public String booleanf(boolean b) {
    return b + "";
  }

  @ExtSyncAction("booleanF")
  public String booleanF(Boolean b) {
    return b + "";
  }

}
