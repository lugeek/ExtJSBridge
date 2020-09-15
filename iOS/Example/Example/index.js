const env = ext.loader.requireModule("env");
const navigator = ext.loader.requireModule("navigator");
const timer = ext.loader.requireModule("timer");
const alert = ext.loader.requireModule("alert");

alert.show({title:"Platform", message:env.platformSync()});

timer.setTimeout({"millseconds":1000, onComplete:function(res){navigator.close();}});
