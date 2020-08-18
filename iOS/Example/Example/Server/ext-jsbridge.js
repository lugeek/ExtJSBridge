/**
 * messageKind  0:normal,1:subscribe,2:unsubscribe
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
        this.target = null;
        this.action = null;
    };
    resolve() {
        return this.target + "/" + this.action + "/" + this.messageId + "/" + this.timestamp + "/1";
    };
};
class ExtUnsubscribe {
    constructor() {
        this.timestamp = new Date().getTime();
        this.target = null;
        this.action = null;
    };
    resolve() {
        return this.target + "/" + this.action + "/" + this.messageId + "/" + this.timestamp + "/2";
    };
};
(function(){
    let ext = {
        //never overwrite
        _messageId: -1,
        //normal message
        _messageMap : new Map(),
        //subscribe message
        _subscriberMap : new Map(),
        _errorCodeMap:{
            "0":"UnkownError",
            "1":"ArgumentError",
            "2":"AuthorityError",
            "3":"UnrecognizedError",
            "4":"Error"
        },
        nextId : function() {
            return ++this._messageId;
        },
        // send message to native
        invoke : function(target, action, params) {
            if (!this._validate(target) || !this._validate(action)) {
                console.error("Invalid target or action");
                return;
            }
            if (params instanceof ExtSubscribe) {
                params.target = target;
                params.action = action;
                this._subscriberMap.set(this._generate(target, action, ""), params);
                window.webkit.messageHandlers.ext.postMessage(params.resolve());
            } else if (params instanceof ExtUnsubscribe) {
                params.target = target;
                params.action = action;
                var obj = this._subscriberMap.get[this._generate(target, action, "")];
                if (obj) {
                    this._subscriberMap.delete(this._generate(target, action, ""));
                    window.webkit.messageHandlers.ext.postMessage(params.resolve());
                }
            } else {
                let message = new ExtMessage(target, action, params);
                if (message.needWaitCallback) {
                    this._messageMap.set(this._generate(target, action, message.messageId), message);
                }
                window.webkit.messageHandlers.ext.postMessage(message.resolve());
            }
        },
        _parse : function (string) {
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
        _convert : function (valueType, string) {
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
                    return nil;
                }
                return object;
            } else if (valueType == 'O') {
                let object = JSON.parse(decodeString);
                return object;
            }
            return string;
        },
        //generate subscriber key
        _generate : function (target, action, id) {
            return target + "/" + action + "/" + id;
        },
        // validate target / action
        _validate : function (params) {
            if (typeof params == 'string' && params.length > 0) {
                return true;
            }
            return false;
        },
        //message invalid/dealloc
        _d: function (m) {
            let resolvedMsg = this._parse(m);
            if (resolvedMsg == null || resolvedMsg == undefined) {
                return;
            }
            let target = resolvedMsg["target"];
            let action = resolvedMsg["action"];
            let value = resolvedMsg["value"];
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
            } else if (kind == "1") {
                let key = this._generate(target, action, "");
                let subscriber = this._subscriberMap.get(key);
                if (subscriber == undefined || subscriber == null) {
                    return;
                }
                if (subscriber.messageId != messageId) {
                    return;
                }
                this._subscriberMap.delete(key);
            }
        },
        //message success
        _s : function (m) {
            let resolvedMsg = this._parse(m);
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
        _f : function (m)  {
            let resolvedMsg = this._parse(m);
            if (resolvedMsg == null || resolvedMsg == undefined) {
                return  new Error();
            }
            let target = resolvedMsg["target"];
            let action = resolvedMsg["action"];
            let value = resolvedMsg["value"];
            let messageId = resolvedMsg["messageId"];
            let key = this._generate(target, action, messageId);
            let message = this._messageMap.get(key);
            if (message == undefined || message == null) {
                return  new Error();
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
        _o: function(m) {
            let resolvedMsg = this._parse(m);
            if (resolvedMsg == null || resolvedMsg == undefined) {
                return new Error();
            }
            let target = resolvedMsg["target"];
            let action = resolvedMsg["action"];
            let value = resolvedMsg["value"];
            let messageId = resolvedMsg["messageId"];
            let subscriber = this._subscriberMap.get(this._generate(target, action, ""));
            if (subscriber == undefined || subscriber == null) {
                return new Error();
            }
            if (typeof subscriber.handler == "function") {
                subscriber.handler(value);
            }
            return true;
        }
    };
    class ExtMessage {
        constructor(target, action, params) {
            this.messageId = ext.nextId();
            this.target = target;
            this.action = action;
            this.params = params;
            this.timestamp = new Date().getTime();
            this.resolvedValue = null;
            this.needWaitCallback = false;
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
                for(let key in this.params) {
                    let item = this.params[key];
                    if (typeof item == 'null' || typeof item == 'undefined' || typeof item == 'boolean' || typeof item == 'string' || typeof item == 'number') {
                        dic[key] = this.params[key];
                        continue;
                    }
                    if (key == 'onSuccess' || key == 'onFail' || key == 'onComplete') {
                        if (typeof item != 'function') {
                            continue;
                        }
                        this.needWaitCallback = true;
                    }
                }
                this.resolvedValue = encodeURIComponent(JSON.stringify(dic));
            }
        };
        resolve() {
            return this.target + "/" + this.action + "/" + this.messageId + "/" + this.timestamp + "/0/" + this.valueType + "/" + this.resolvedValue;
        };
    };
    if (window.ext == null || window.ext == undefined) {
        window.ext = ext;
    }
})();
