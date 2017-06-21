(function () {

    if (typeof VideoSubscriberAccount === 'undefined') {

        var listeners = [];
        var outgoingMessages = [];

        VideoSubscriberAccount = {

            addMessageListener : function addMessageListener (listener) {
                if (typeof listener !== 'function') {
                    throw new TypeError('The message listener parameter must be a function.');
                }

                listeners.push(listener);
            },

            removeMessageListener : function removeMessageListener (listener) {
                if (typeof listener !== 'function') {
                    throw new TypeError('The message listener parameter must be a function.');
                }

                var listenerIndex = listeners.lastIndexOf(listener);
                if (listenerIndex < 0) {
                    throw new RangeError('The provided message listener is not registered.');
                }

                listeners.splice(listenerIndex, 1);
            },

            postMessage : function postMessage (message, targetOrigin) {
                if (typeof message !== 'string') {
                    throw new TypeError('The message parameter must be a string.');
                }

                if (typeof targetOrigin !== 'string') {
                    throw new TypeError('The target parameter must be a string.');
                }

                var messageHandler = {};

                if ("____VS_MESSAGE_ENVIRONMENT_NAME____" === "web") {
                    messageHandler.postMessage = function postMessage (message) {
                        outgoingMessages.push(message);
                        window.location = "____VS_MESSAGE_NOTIFICATION_URL____";
                    };
                } else {
                    var doc = getActiveDocument();
                    if (typeof doc === 'undefined') {
                        throw new Error('Unable to obtain the active document.');
                    }

                    var templateElementName = 'webAuthenticationTemplate';
                    var templateElement = doc.getElementsByTagName(templateElementName).item(0);
                    if (typeof templateElement === 'undefined') {
                        throw new Error('There is no ' + templateElementName + 'element in the active document.');
                    }

                    messageHandler = templateElement.getFeature("WebMessagePort", null);
                }

                messageHandler.postMessage({"body" : message, "target" : targetOrigin});
            },

            _dispatchMessage : function _dispatchMessage (message) {
                var copiedListeners = listeners.slice();
                copiedListeners.forEach(function (listener) {
                    listener(message);
                });
            },

            _retrieveMessages : function _retrieveMessages () {
                var pendingMessages = JSON.stringify(outgoingMessages);
                outgoingMessages.length = 0;
                return pendingMessages;
            }
        };

    }

})();
