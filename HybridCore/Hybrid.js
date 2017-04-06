;(function() {
        'use strict';
        if (window.ReflectJavascriptBridge) {
            return;
        }
        
        window.ReflectJavascriptBridge = {
        addObject: addObject,
        dequeueCommandQueue: dequeueCommandQueue,
        sendCommand: sendCommand,
        checkAndCall: checkAndCall,
        callback: callback
        };
        
        var nativeObjects = [];
        var commandQueue = [];
        var responseCallbacks = [];
        var uniqueCallbackId = 0;
        var iFrame;
        var requestMessage = "ReflectJavascriptBridge://_ReadyForCommands_";
        
        if (window.RJBRegisteredFunctions) {
            var index;
            for (index in window.RJBRegisteredFunctions) {
                var funcInfo = window.RJBRegisteredFunctions[index];
                window.ReflectJavascriptBridge[funcInfo.name] = funcInfo.func;
            }
            delete window.RJBRegisteredFunctions;
        }
        
        function checkAndCall(methodName, args) {
            var method = window.ReflectJavascriptBridge[methodName];
            if (method && typeof method === 'function') {
                method.apply(null, args);
            }
        }
        
        function callback(callbackId, returnValue) {
            if (responseCallbacks[callbackId]) {
                responseCallbacks[callbackId](returnValue);
                delete responseCallbacks[callbackId];
            }
        }
        
        // 用json描述一个对象，name为变量的命名
        function addObject(objc, name) {
            nativeObjects[name] = objc;
            window.ReflectJavascriptBridge[name] = objc;
        }
        
        // 有新的command时向native发送消息,通知native获取command
        function sendReadyToNative() {
            iFrame.src = requestMessage;
        }
        
        // 该方法由native调用，返回所有的commands
        function dequeueCommandQueue() {
            var json = JSON.stringify(commandQueue);
            commandQueue = [];
            return json;
        }
        
        // 添加一条command并通知native
        function sendCommand(objc, method, args, returnType) {
            var command = {
                "className": objc["className"],
                "identifier": objc["identifier"],
                "args": args,
                "returnType": returnType
            };
            if (method) {
                command["method"] = objc.maps[method];
            }
            
            var lastArg = args[args.length - 1];
            if (returnType != 'v' && typeof lastArg === 'function') {
                responseCallbacks[uniqueCallbackId] = lastArg;
                command["callbackId"] = uniqueCallbackId; ++uniqueCallbackId;
            }
            commandQueue.push(command);
            sendReadyToNative();
        }
        
        // 添加一个iFrame用于发送信息
        iFrame = document.createElement("iframe");
        iFrame.style.display = 'none';
        iFrame.src = requestMessage;
        document.documentElement.appendChild(iFrame)
    })();