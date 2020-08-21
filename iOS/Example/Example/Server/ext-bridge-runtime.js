/**
 * messageKind  0:normal-sync,1:normal-async,2:subscribe,3:unsubscribe
 *
 * message format
 * /target/action/messageId/timestamp/messageKind/valueType/value
 *
 * type S : string
 * type N : number
 * type O : object
 * type A : array
 * type E : error
 */

class ExtSubscribe {
    constructor(handler) {
        this.messageId = ext.nextId();
        this.timestamp = new Date().getTime();
        this.handler = handler;
        this.isSync = true;
        this.target = null;
        this.action = null;
    };
    resolve() {
        return this.target + "/" + this.action + "/" + this.messageId + "/" + this.timestamp + "/2";
    };
};
class ExtUnsubscribe {
    constructor() {
        this.timestamp = new Date().getTime();
        this.isSync = true;
        this.target = null;
        this.action = null;
    };
    resolve() {
        return this.target + "/" + this.action + "/" + this.messageId + "/" + this.timestamp + "/3";
    };
};
//do not use
class ExtMessage {
    constructor(target, action, params) {
        this.messageId = ext.nextId();
        this.target = target;
        this.action = action;
        this.isSync = true;
        this.params = params;
        this.timestamp = new Date().getTime();
        this.resolvedValue = null;
        if (typeof params == 'boolean') {
            this.valueType = "N";
            if (params) {
                this.resolvedValue = 1;
            } else {
                this.resolvedValue = 0;
            }
        } else if (typeof params == 'number') {
            this.valueType = "N";
            this.resolvedValue = params;
        } else if (typeof params == 'null' || typeof params == 'undefined') {
            this.valueType = "S";
            this.resolvedValue = "";
        } else if (typeof params == 'string') {
            this.valueType = "S";
            this.resolvedValue = encodeURIComponent(params);
        } else if (params instanceof Array) {
            this.valueType = "E";
            this.resolvedValue = encodeURIComponent(params);
        } else if (params instanceof Array) {
            this.valueType = "A";
            this.resolvedValue = encodeURIComponent(JSON.stringify(params));
        } else {
            this.valueType = "O";
            let dic = {};
            for (let key in this.params) {
                let item = this.params[key];
                if ((key == 'onSuccess' || key == 'onFail' || key == 'onComplete') && typeof item == 'function') {
                    this.isSync = false;
                }
                if (typeof item == 'null' || typeof item == 'undefined' || typeof item == 'boolean' || typeof item == 'string' || typeof item == 'number') {
                    dic[key] = this.params[key];
                    continue;
                }
            }
            this.resolvedValue = encodeURIComponent(JSON.stringify(dic));
        }
    };
    resolve() {
        return this.target + "/" + this.action + "/" + this.messageId + "/" + this.timestamp + "/" + (this.isSync ? 0 : 1) + "/" + this.valueType + "/" + this.resolvedValue;
    };
};
(function () {
    let extBridge = {
        //never overwrite
        _messageId: -1,
        //normal message
        _messageMap: new Map(),
        //subscribe message
        _subscriberMap: new Map(),
        _errorCodeMap: {
            "0": "UnkownError",
            "1": "ArgumentError",
            "2": "AuthorityError",
            "3": "UnrecognizedError",
            "4": "Error"
        },
        nextId: function () {
            return ++this._messageId;
        },
        // send message to native
        invoke: function (target, action, params) {
            if (!this._validate(target) || !this._validate(action)) {
                console.error("Invalid target or action");
                return false;
            }
            if (params instanceof ExtSubscribe) {
                params.target = target;
                params.action = action;
                let key = this._generate(target, action, "");
                var ret = false;
                if (this._isIOS) {
                    var ret = window.prompt("ext", params.resolve());
                    let resolvedMsg = this._parseSyncString(ret);
                    if (resolvedMsg.value == 1) {
                        this._subscriberMap.set(key, params);
                        ret = true;
                    } else {
                        console.log("Client can not handle this subscriber");
                    }
                } else if (this._isAndroid) {
                    var ret = window.ext.postMessage(params.resolve());
                    let resolvedMsg = this._parseSyncString(ret);
                    if (resolvedMsg.value == 1) {
                        this._subscriberMap.set(key, params);
                        ret = true;
                    } else {
                        console.log("Client can not handle this subscriber");
                    }
                }
                return ret;
            } else if (params instanceof ExtUnsubscribe) {
                params.target = target;
                params.action = action;
                let key = this._generate(target, action, "");
                var obj = this._subscriberMap.get(key);
                if (obj) {
                    this._subscriberMap.delete(key);
                }
                return true;
            } else {
                let message = new ExtMessage(target, action, params);
                if (this._isIOS) {
                    if (!message.isSync) {
                        this._messageMap.set(this._generate(target, action, message.messageId), message);
                        window.webkit.messageHandlers.ext.postMessage(message.resolve());
                        return null;
                    } else {
                        let ret = window.prompt("ext", message.resolve());
                        let resolvedMsg = this._parseSyncString(ret);
                        if (resolvedMsg == null || resolvedMsg == undefined) {
                            return null;
                        }
                        return resolvedMsg["value"];
                    }
                } else if (this._isAndroid) {
                    if (!message.isSync) {
                        this._messageMap.set(this._generate(target, action, message.messageId), message);
                        window.ext.postMessage(message.resolve());
                        return null;
                    } else {
                        let ret = window.ext.postMessage(message.resolve());
                        let resolvedMsg = this._parseSyncString(ret);
                        if (resolvedMsg == null || resolvedMsg == undefined) {
                            return null;
                        }
                        return resolvedMsg["value"];
                    }
                }
            }
            return null;
        },
        isAndroid: function () {
            var u = navigator.userAgent, app = navigator.appVersion;
            return u.indexOf('Android') > -1 || u.indexOf('Adr') > -1;
        },
        isIOS: function () {
            var u = navigator.userAgent, app = navigator.appVersion;
            return !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/);
        },
        _parseSubscribeString: function (string) {
            var resolvedMsg = {};
            let array = string.split("/");
            if (array.length > 0) {
                let value = this._convert("A", array[0]);
                if (value instanceof Array) {
                    resolvedMsg["targets"] = value;
                }
            }
            if (array.length > 1) {
                resolvedMsg["action"] = array[1];
            }
            if (array.length > 2) {
                resolvedMsg["valueType"] = array[2];
            }
            if (array.length > 3) {
                let value = this._convert(array[2], array[3]);
                if (value != null && value != undefined) {
                    resolvedMsg["value"] = value;
                }
            }
            return resolvedMsg;
        },
        _parseSyncString: function (string) {
            var resolvedMsg = {};
            let array = string.split("/");
            if (array.length > 0) {
                resolvedMsg["valueType"] = array[0];
            }
            if (array.length > 1) {
                let value = this._convert(array[0], array[1]);
                if (value != null && value != undefined) {
                    resolvedMsg["value"] = value;
                }
            }
            return resolvedMsg;
        },
        _parseAsyncString: function (string) {
            var resolvedMsg = {};
            let array = string.split("/");
            if (array.length > 0) {
                resolvedMsg["target"] = array[0];
            }
            if (array.length > 1) {
                resolvedMsg["action"] = array[1];
            }
            if (array.length > 2) {
                resolvedMsg["messageId"] = array[2];
            }
            if (array.length > 3) {
                resolvedMsg["timestamp"] = array[3];
            }
            if (array.length > 4) {
                resolvedMsg["kind"] = array[4];
            }
            if (array.length > 5) {
                resolvedMsg["valueType"] = array[5];
            }
            if (array.length > 6) {
                let value = this._convert(array[5], array[6]);
                if (value != null && value != undefined) {
                    resolvedMsg["value"] = value;
                }
            }
            return resolvedMsg;
        },
        //conver string to value
        _convert: function (valueType, string) {
            let decodeString = decodeURI(string);
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
                    err.name = this._errorCodeMap[err.code];
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
        //generate subscriber key
        _generate: function (target, action, id) {
            return target + "/" + action + "/" + id;
        },
        // validate target / action
        _validate: function (params) {
            if (typeof params == 'string' && params.length > 0) {
                return true;
            }
            return false;
        },
        //client uncallback
        _d: function (m) {
            let resolvedMsg = this._parseAsyncString(m);
            if (resolvedMsg == null || resolvedMsg == undefined) {
                return;
            }
            let target = resolvedMsg["target"];
            let action = resolvedMsg["action"];
            let kind = resolvedMsg["kind"];
            let messageId = resolvedMsg["messageId"];
            if (kind == "0") {
                let key = this._generate(target, action, messageId);
                let message = this._messageMap.get(key);
                if (message == undefined || message == null) {
                    return;
                }
                let err = new Error();
                err.name = "Unresponde";
                if (typeof message.params["onFail"] == "function") {
                    message.params["onFail"](err);
                }
                if (typeof message.params.onComplete == "function") {
                    message.params["onComplete"](err);
                }
                this._messageMap.delete(key);
            }
        },
        //message success
        _s: function (m) {
            console.log(111112 + m);
            let resolvedMsg = this._parseAsyncString(m);
            console.log(resolvedMsg);
            if (resolvedMsg == null || resolvedMsg == undefined) {
                return new Error();
            }
            let target = resolvedMsg["target"];
            let action = resolvedMsg["action"];
            let value = resolvedMsg["value"];
            let messageId = resolvedMsg["messageId"];
            let key = this._generate(target, action, messageId);
            console.log(111112 + "key" + key);
            let message = this._messageMap.get(key);
            console.log(111112 + "message" + message);
            if (message == undefined || message == null) {
                return new Error();
            }
            console.log(111112 + "message" + "ssss");
            if (typeof message.params["onSuccess"] == "function") {
                message.params["onSuccess"](value);
            }
            if (typeof message.params["onComplete"] == "function") {
                message.params["onComplete"](value);
            }
            this._messageMap.delete(key);
            return true;
        },
        //fail
        _f: function (m) {
            let resolvedMsg = this._parseAsyncString(m);
            if (resolvedMsg == null || resolvedMsg == undefined) {
                return new Error();
            }
            let target = resolvedMsg["target"];
            let action = resolvedMsg["action"];
            let value = resolvedMsg["value"];
            let messageId = resolvedMsg["messageId"];
            let key = this._generate(target, action, messageId);
            let message = this._messageMap.get(key);
            if (message == undefined || message == null) {
                return new Error();
            }
            if (typeof message.params["onFail"] == "function") {
                message.params["onFail"](value);
            }
            if (typeof message.params.onComplete == "function") {
                message.params["onComplete"](value);
            }
            this._messageMap.delete(key);
            return true;
        },
        //observe
        _o: function (m) {
            let resolvedMsg = this._parseSubscribeString(m);
            if (resolvedMsg == null || resolvedMsg == undefined) {
                return new Error();
            }
            let targets = resolvedMsg["targets"];
            let action = resolvedMsg["action"];
            let value = resolvedMsg["value"];
            for (var i = 0; i < targets.length; i++) {
                let target = targets[i];
                let key = this._generate(target, action, "");
                let subscriber = this._subscriberMap.get(key);
                if (subscriber != null && subscriber != undefined && typeof subscriber.handler == "function") {
                    subscriber.handler(value);
                }
            }
            return true;
        }
    };
    if (window.ext == null || window.ext == undefined) {
        window.ext = extBridge;
        extBridge._isIOS = extBridge.isIOS();
        extBridge._isAndroid = extBridge.isAndroid();
    } else {
        window.ext._messageId = extBridge._messageId;
        window.ext._messageMap = extBridge._messageMap;
        window.ext._subscriberMap = extBridge._subscriberMap;
        window.ext._errorCodeMap = extBridge._errorCodeMap;
        window.ext._isIOS = extBridge.isIOS();
        window.ext._isAndroid = extBridge.isAndroid();
        window.ext.nextId = extBridge.nextId;
        window.ext.invoke = extBridge.invoke;
        window.ext.isIOS = extBridge.isIOS;
        window.ext.isAndroid = extBridge.isAndroid;
        window.ext._parseAsyncString = extBridge._parseAsyncString;
        window.ext._convert = extBridge._convert;
        window.ext._generate = extBridge._generate;
        window.ext._validate = extBridge._validate;
        window.ext._d = extBridge._d;
        window.ext._s = extBridge._s;
        window.ext._f = extBridge._f;
        window.ext._o = extBridge._o;
    }
})();
