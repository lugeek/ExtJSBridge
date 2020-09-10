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
        removeListenerForMessage(messageName) {
            this.map.set(messageName, new Set());
        }
        post (messageName, value) {
            value = ext.parseShortString(value).value;
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
    class ExtSession {
        constructor(target, action, params) {
            this.sID = ext.nextId();
            this.target = target;
            this.action = action;
            this.params = params;
            this.formatedValue = ext.formatJSValue(params);
        };
        compact() {
            return this.target + "/" + this.action + "/" + this.sID + "/" + this.formatedValue;
        };
    };
    let bridge = {
        _sID : -1,
        //session map
        _sm : new Map(),
        //module Class Map
        _mcm : new Map(),
        //module Instance Map
        _mim : new Map(),
        _platform : "unkown",
        nextId : function () {
            return ++this._sID;
        },
        installModule : function (names) {
            if (!(names instanceof String) && typeof names != 'string' && !(names instanceof Array)) {
                console.error("TypeError: invalid names type" + typeof names);
                return;
            }
            if (!(names instanceof Array)) {
                names = [names];
            }
            let moduleNameSet = new Set();
            for (var i = 0; i < names.length; i++) {
                var name = names[i];
                var moduleClass = this._mcm.get(name);
                if (!moduleClass) {
                    moduleNameSet.add(name);
                }
            }
            if (moduleNameSet.size == 0) {
                return true;
            }
            let result = this._i("bin", "installModule", Array.from(moduleNameSet));
            if (result == null || result == undefined) {
                console.error("InstallModuleError: failed with module [" + Array.from(moduleNameSet) + "]");
                return false;
            }
            var code = "";
            for (let name in result) {
                let item = result[name];
                code += this._cimc(item, name);
                moduleNameSet.delete(name);
            }
            globalThis.eval(code);
            if (moduleNameSet.size > 0) {
                console.error("InstallModuleError: failed with module [" + Array.from(moduleNameSet)) + "]";
            }
            return true;
        },
        requireModule : function (name) {
            var instance = this._mim.get(name);
            if (!instance) {
                var moduleClass = this._mcm.get(name);
                if (!moduleClass) {
                    let state = this.installModule(name);
                    if (!state) {
                        return null;
                    }
                    moduleClass = this._mcm.get(name);
                }
                instance = new moduleClass;
                instance.channel = new ExtMessageChannel;
                this._mim.set(name, instance);
                this._i("bin", "requireModule", name);
            }
            return instance;
        },
        formatJSValue : function (params) {
            let typeStr = "S";
            let valueStr = "";
            if (typeof params == 'boolean') {
                typeStr = "B";
                valueStr = params;
            } else if (typeof params == 'number') {
                typeStr = "N";
                valueStr = encodeURIComponent(params);
            } else if (typeof params == 'null' || typeof params == 'undefined') {
                typeStr = "S";
                valueStr = "";
            } else if (typeof params == 'string') {
                typeStr = "S";
                valueStr = encodeURIComponent(params);
            } else if (params instanceof Error) {
                typeStr = "E";
                let error = {n:params.name, m:params.message, c:params.code?params.code:-1};
                valueStr = encodeURIComponent(JSON.stringify(error));
            } else if (params instanceof Array) {
                typeStr = "A";
                valueStr = encodeURIComponent(JSON.stringify(params));
            } else {
                typeStr = "O";
                let dic = {};
                for (let key in params) {
                    let item = params[key];
                    if (key == 'onProgress' || key == 'onSuccess' || key == 'onFail' || key == 'onComplete' || typeof item == 'function') {
                        continue;
                    }
                    dic[key] = item;
                }
                valueStr = encodeURIComponent(JSON.stringify(dic));
            }
            return typeStr + "/" + valueStr;
        },
        
        //conver string to value
        convertValue : function (valueType, string) {
            let decodeString = decodeURIComponent(string);
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
        // format: type/value
        parseShortString : function (string) {
            if(!(string instanceof String) && typeof string != 'string') {
                string = "";
            }
            var uncompactSession = {valueType:"S", value:string};
            let array = string.split("/");
            if (array.length > 0) {
                uncompactSession.valueType = array[0];
            }
            if (array.length > 1) {
                let value = this.convertValue(array[0], array[1]);
                if (value != null && value != undefined) {
                    uncompactSession.value = value;
                }
            }
            return uncompactSession;
        },
        parseString : function (string) {
            if(!(string instanceof String) && typeof string != 'string') {
                string = "";
            }
            var uncompactSession = {valueType:"S", value:string};
            let array = string.split("/");
            if (array.length > 0) {
                uncompactSession.target = array[0];
            }
            if (array.length > 1) {
                uncompactSession.action = array[1];
            }
            if (array.length > 2) {
                uncompactSession.sID = array[2];
            }
            if (array.length > 3) {
                uncompactSession.valueType = array[3];
            }
            if (array.length > 4) {
                let value = this.convertValue(array[3], array[4]);
                if (value != null && value != undefined) {
                    uncompactSession.value = value;
                }
            }
            return uncompactSession;
        },
        generateKey : function (target, action, id) {
            return target + "/" + action + "/" + id;
        },
        // validate target / action
        validate : function (params) {
            if (typeof params == 'string' && params.length > 0) {
                return true;
            }
            return false;
        },
        platform : function () {
            return (native_ext != null ? native_ext.platform() : "unkown");
        },
        // create Injection Module Code
        _cimc : function (cls, name) {
            return '(function(){'+ cls +'ext._mcm.set("' + name + '", _);})();'
        },
        // invoke native target action
        _i : function (target, action, params, isSync) {
            if (!this.validate(target) || !this.validate(action)) {
                console.error("Invalid target or action");
                return false;
            }
            let session = new ExtSession(target, action, params);
            if (!isSync) {
                let map = this._sm.get(target);
                if (!map) {
                    map = new Map();
                    this._sm.set(target, map);
                }
                map.set(this.generateKey(target, action, session.sID), session);
            }
            let ret = native_ext.invoke(session.target, session.action, session.sID, session.valueType, session.params);
            let uncompactSession = this.parseShortString(ret);
            if (uncompactSession == null || uncompactSession == undefined) {
                return null;
            }
            return uncompactSession.value;
        },
        //session success
        _p : function (m) {
            let uncompactSession = this.parseString(m);
            if (uncompactSession == null || uncompactSession == undefined) {
                return;
            }
            let target = uncompactSession.target;
            let action = uncompactSession.action;
            let value = uncompactSession.value;
            let sID = uncompactSession.sID;
            let map = this._sm.get(target);
            if (!map) {
                return;
            }
            let key = this.generateKey(target, action, sID);
            let session = map.get(key);
            if (session == undefined || session == null || session.params == undefined || session.params == null) {
                return;
            }
            if (typeof session.params.onProgress == "function") {
                session.params.onProgress(value);
            }
            return;
        },
        //session success
        _s : function (m) {
            let uncompactSession = this.parseString(m);
            if (uncompactSession == null || uncompactSession == undefined) {
                return;
            }
            let target = uncompactSession.target;
            let action = uncompactSession.action;
            let value = uncompactSession.value;
            let sID = uncompactSession.sID;
            let map = this._sm.get(target);
            if (!map) {
                return;
            }
            let key = this.generateKey(target, action, sID);
            let session = map.get(key);
            if (session == undefined || session == null || session.params == undefined || session.params == null) {
                return;
            }
            if (typeof session.params.onSuccess == "function") {
                session.params.onSuccess(value);
            }
            if (typeof session.params.onComplete == "function") {
                session.params.onComplete(value);
            }
            map.delete(key);
            return;
        },
        //fail
        _f : function (m) {
            let uncompactSession = this.parseString(m);
            if (uncompactSession == null || uncompactSession == undefined) {
                return;
            }
            let target = uncompactSession.target;
            let action = uncompactSession.action;
            let value = uncompactSession.value;
            let sID = uncompactSession.sID;
            let map = this._sm.get(target);
            if (!map) {
                return;
            }
            let key = this.generateKey(target, action, sID);
            let session = map.get(key);
            if (session == undefined || session == null || session.params == undefined || session.params == null) {
                return;
            }
            if (typeof session.params.onFail == "function") {
                session.params.onFail(value);
            }
            if (typeof session.params.onComplete == "function") {
                session.params.onComplete(value);
            }
            map.delete(key);
        },
    };
    bridge._platform = bridge.platform();
    if (globalThis.ext == null || globalThis.ext == undefined) {
        globalThis.ext = bridge;
    }
})();
