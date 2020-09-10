const env = ext.requireModule("env");
const navigator = ext.requireModule("navigator");
const timer = ext.requireModule("timer");
const alert = ext.requireModule("alert");

alert.show({title:"Platform", message:env.platformSync()});

timer.setTimeout({"millseconds":1000, onComplete:function(res){navigator.close();}});
