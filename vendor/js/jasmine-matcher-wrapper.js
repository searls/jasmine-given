/* jasmine-matcher-wrapper - 0.0.2
 * Wraps Jasmine 1.x matchers for use with Jasmine 2
 * https://github.com/testdouble/jasmine-matcher-wrapper
 */
(function() {
  var __slice = [].slice,
    __hasProp = {}.hasOwnProperty;

  (function(jasmine) {
    var comparatorFor;
    if (jasmine == null) {
      return typeof console !== "undefined" && console !== null ? console.warn("jasmine was not found. Skipping jasmine-matcher-wrapper. Verify your script load order.") : void 0;
    }
    if (jasmine.matcherWrapper != null) {
      return;
    }
    comparatorFor = function(matcher, isNot) {
      return function() {
        var actual, context, message, params, pass, _ref;
        actual = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        context = {
          actual: actual,
          isNot: isNot
        };
        pass = matcher.apply(context, params);
        if (isNot) {
          pass = !pass;
        }
        if (!pass) {
          message = (_ref = context.message) != null ? _ref.apply(context, params) : void 0;
        }
        return {
          pass: pass,
          message: message
        };
      };
    };
    return jasmine.matcherWrapper = {
      wrap: function(matchers) {
        var matcher, name, wrappedMatchers;
        if (jasmine.addMatchers == null) {
          return matchers;
        }
        wrappedMatchers = {};
        for (name in matchers) {
          if (!__hasProp.call(matchers, name)) continue;
          matcher = matchers[name];
          wrappedMatchers[name] = function() {
            return {
              compare: comparatorFor(matcher, false),
              negativeCompare: comparatorFor(matcher, true)
            };
          };
        }
        return wrappedMatchers;
      }
    };
  })(jasmine || getJasmineRequireObj());

}).call(this);
