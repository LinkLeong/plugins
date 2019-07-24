var exec = require('cordova/exec');
exports.coolMethod = function (method, action, dataStr, success, error) {

    var toReturn, deferred, injector, $q;
    if (success === undefined) {
        if (window.jQuery) {
            //alert("jquery" + window.jQuery);

            deferred = jQuery.Deferred();
            success = deferred.resolve;
            fail = deferred.reject;
            toReturn = deferred;
        } else if (window.angular) {
            //alert("angular" + window.angular);

            injector = angular.injector(["ng"]);
            $q = injector.get("$q");
            deferred = $q.defer();
            success = deferred.resolve;
            fail = deferred.reject;
            toReturn = deferred.promise;
        } else if (window.when && window.when.promise) {
            //alert("when" + window.when);

            deferred = when.defer();
            success = deferred.resolve;
            fail = deferred.reject;
            toReturn = deferred.promise;
        } else if (window.Promise) {
           // alert("promise" + window.Promise);
            toReturn = new Promise(function (c, e) {
                success = c;
                fail = e;
            });
        } else if (window.WinJS && window.WinJS.Promise) {
            //alert("winjs" + window.WinJS);
            toReturn = new WinJS.Promise(function (c, e) {
                success = c;
                fail = e;
            });
        } else {
            alert("没有安装jQuery/AngularJS/Promise/WinJS.Promise")
            return console.error('AppVersion either needs a success callback, or jQuery/AngularJS/Promise/WinJS.Promise defined for using promises');
        }
    }



    exec(success, error, 'cryptoFxeye', 'coolMethod', [method, action, dataStr]);
    return toReturn;
};
