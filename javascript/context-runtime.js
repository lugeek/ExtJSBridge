(function(){
    class ExtMessage {
        constructor(name, data){
            this.name = name;
            this.data = data;
        }
    };
    class ExtMessageChannel {
        constructor(){
            this.map = new Map();
        }
        addListener(messageName, handler) {
            let set = this.map.get(messageName);
            if (!set) {
                set = new Set();
                this.map.set(messageName, set);
            }
            set.add(handler);
        }
        removeListener(messageName, handler) {
            let set = this.map.get(messageName);
            if (!set) {
                return;
            }
            set.delete(handler);
        }
        removeListenerForMessageName(messageName) {
            this.map.set(messageName, new Set());
        }
        post (messageName, value) {
            value = ext.parseCompactValue(value).value;
            let msg = new ExtMessage(messageName, value);
            let set = this.map.get(messageName);
            if (set == null || set == undefined) {
                return;
            }
            set.forEach(function(handler) {
                handler(msg);
            });
        }
    };
    if (globalThis.ExtMessageChannel == null) {
        globalThis.ExtMessageChannel = ExtMessageChannel;
    }
    let bridge = {
        _sID : -1,
        //session map
        _sm : new Map(),
        //module Class Map
        _mcm : new Map(),
        //core module instance Map
        _cmim : new Map(),
        //module Instance Map
        _mim : new Map(),
        //compact Session Variable List
        _cskl : ["target", "action", "sID", "valueType", "value"],
        //compact Value Variable List
        _cvkl : ["valueType", "value"],
        _platform : "unkown",
        _contextType : "jsvm",
        _globalObject : globalThis,
        _coreLoaded : false,
        nextId : function () {
            return ++this._sID;
        },
        getValueType : function (value) {
            if (typeof value == 'boolean') {
                return "B";
            } else if (typeof value == 'number') {
                return "N";
            } else if (value == null || value == undefined) {
                return "S";
            } else if (typeof value == 'string') {
                return "S";
            } else if (value instanceof Error) {
                return "E";
            } else if (value instanceof Array) {
                return "A";
            }
            return "O";
        },
        convertValue : function (value) {
            let valueStr = "";
            if (typeof value == 'boolean') {
                valueStr = value;
            } else if (typeof value == 'number') {
                valueStr = value;
            } else if (value == null || value == undefined) {
                valueStr = "";
            } else if (typeof value == 'string') {
                valueStr = value;
            } else if (value instanceof Error) {
                let error = {n:value.name, m:value.message, c:value.code?value.code:-1};
                valueStr = JSON.stringify(error);
            } else if (value instanceof Array) {
                valueStr = JSON.stringify(value);
            } else {
                let dic = {};
                for (let key in value) {
                    let item = value[key];
                    if (key == 'onProgress' || key == 'onSuccess' || key == 'onFail' || key == 'onComplete' || typeof item == 'function') {
                        continue;
                    }
                    dic[key] = item;
                }
                valueStr = JSON.stringify(dic);
            }
            return valueStr;
        },
        //conver valueString to value
        convertStringValue : function (valueType, string) {
            let decodeString = string;
            if (valueType == "S") {
                return decodeString;
            } else if (valueType == "N") {
                return Number(string);
            } else if (valueType == "E") {
                let err = new Error();
                let object = JSON.parse(decodeString);
                if (object != null && object != undefined) {
                    err.message = object["m"];
                    err.code = object["c"];
                    err.name = object["n"];
                }
                return err;
            } else if (valueType == "A") {
                let object = JSON.parse(decodeString);
                if (!(object instanceof Array)) {
                    return null;
                }
                return object;
            } else if (valueType == 'O') {
                let object = JSON.parse(decodeString);
                return object;
            }
            return string;
        },
        //value to compactValue, format valyeType/value
        compactValue : function (value) {
            return this.getValueType(value) + "/" + this.convertValue(value);
        },
        // format: valueType/value
        parseCompactValue : function (string) {
            if(!(string instanceof String) && typeof string != 'string') {
                string = "";
            }
            var result = {valueType:"S", value:string};
            let length = string.length;
            let start = 0;
            let index = 0;
            for (let i = 0; i < length; i++) {
                if (string.charAt(i) == '/') {
                    let key = this._cvkl[index];
                    let value = string.substring(start, i);
                    result[key] = value;
                    index++;
                    start = i + 1;
                    if (index + 1 == this._cvkl.length) {
                        let key = this._cvkl[index];
                        let value = this.convertStringValue(result.valueType, string.substring(start));
                        result[key] = value;
                        break;
                    }
                }
            }
            return result;
        },
        compactSession : function (session) {
            return session.target + "/" + session.action + "/" + session.sID + "/" + session.valueType + '/' + session.value;
        },
        // format: target/action/sID/valueType/value
        parseCompactSession : function (string) {
            if(!(string instanceof String) && typeof string != 'string') {
                string = "";
            }
            var session = {valueType:"S", value:string};
            let length = string.length;
            let start = 0;
            let index = 0;
            for (let i = 0; i < length; i++) {
                if (string.charAt(i) == '/') {
                    let key = this._cskl[index];
                    let value = string.substring(start, i);
                    session[key] = value;
                    index++;
                    start = i + 1;
                    if (index + 1 == this._cskl.length) {
                        let key = this._cskl[index];
                        let value = this.convertStringValue(session.valueType, string.substring(start));
                        session[key] = value;
                        break;
                    }
                }
            }
            return session;
        },
        generateKey : function (target, action, id) {
            return target + "/" + action + "/" + id;
        },
        // validate target / action
        validate : function (string) {
            if (typeof string == 'string' && string.length > 0) {
                return true;
            }
            return false;
        },
        platform : function () {
            return (native_ext != null ? native_ext.platform() : "unkown");
        },
        _loadCore : function () {
            if (this._coreLoaded) {
                return;
            }
            this._coreLoaded = true;
            let result = this._i("ext", "loadCore", null);
            var code = "";
            for (let name in result) {
                let item = result[name];
                code += this._cimc(item, name);
            }
            globalThis.eval(code);
            for (let name in result) {
                var instance = this[name];
                if (!instance) {
                    var moduleClass = this._mcm.get(name);
                    if (!moduleClass) {
                        continue;
                    }
                    instance = new moduleClass();
                    instance.channel = new ExtMessageChannel();
                    this[name] = instance;
                    this._mim.set(name, instance);
                    this._cmim.set(name, instance);
                }
            }
        },
        _exec : function (session) {
            return native_ext.invoke(session.target, session.action, session.sID, session.valueType, session.value);
        },
        // create Injection Module Code
        _cimc : function (cls, name) {
            return '(function(){'+ cls +'ext._mcm.set("' + name + '", _);})();'
        },
        // invoke native target action
        _i : function (target, action, arg, isSync) {
            if (!this.validate(target) || !this.validate(action)) {
                console.error("Invalid target or action");
                return false;
            }
            let session = {
                "target":target,
                "action":action,
                "sID":this.nextId(),
                "valueType":this.getValueType(arg),
                "value":this.convertValue(arg),
                "arg":arg,
            };
            if (!isSync) {
                let map = this._sm.get(target);
                if (!map) {
                    map = new Map();
                    this._sm.set(target, map);
                }
                map.set(this.generateKey(target, action, session.sID), session);
            }
            let ret = this._exec(session);
            return this.parseCompactValue(ret).value;
        },
        //session success
        _p : function (m) {
            let session = this.parseCompactSession(m);
            if (session == null || session == undefined) {
                return;
            }
            let target = session.target;
            let action = session.action;
            let value = session.value;
            let sID = session.sID;
            let map = this._sm.get(target);
            if (!map) {
                return;
            }
            let key = this.generateKey(target, action, sID);
            session = map.get(key);
            if (session == undefined || session == null || session.arg == undefined || session.arg == null) {
                return;
            }
            if (typeof session.arg.onProgress == "function") {
                session.arg.onProgress(value);
            }
            return;
        },
        //session success
        _s : function (m) {
            let session = this.parseCompactSession(m);
            if (session == null || session == undefined) {
                return;
            }
            let target = session.target;
            let action = session.action;
            let value = session.value;
            let sID = session.sID;
            let map = this._sm.get(target);
            if (!map) {
                return;
            }
            let key = this.generateKey(target, action, sID);
            session = map.get(key);
            if (session == undefined || session == null || session.arg == undefined || session.arg == null) {
                return;
            }
            if (typeof session.arg.onSuccess == "function") {
                session.arg.onSuccess(value);
            }
            if (typeof session.arg.onComplete == "function") {
                session.arg.onComplete(value);
            }
            map.delete(key);
            return;
        },
        //fail
        _f : function (m) {
            let session = this.parseCompactSession(m);
            if (session == null || session == undefined) {
                return;
            }
            let target = session.target;
            let action = session.action;
            let value = session.value;
            let sID = session.sID;
            let map = this._sm.get(target);
            if (!map) {
                return;
            }
            let key = this.generateKey(target, action, sID);
            session = map.get(key);
            if (session == undefined || session == null || session.arg == undefined || session.arg == null) {
                return;
            }
            if (typeof session.arg.onFail == "function") {
                session.arg.onFail(value);
            }
            if (typeof session.arg.onComplete == "function") {
                session.arg.onComplete(value);
            }
            map.delete(key);
        },
    };
    bridge._platform = bridge.platform();
    if (globalThis.ext == null || globalThis.ext == undefined) {
        globalThis.ext = bridge;
    }
    bridge._loadCore();
})();
