(function() {

  (function(jasmine) {
    var mostRecentlyUsed, o;
    beforeEach(function() {
      return this.addMatchers({
        toHaveReturnedFalseFromThen: function(context, n) {
          var exception, result;
          result = false;
          exception = void 0;
          try {
            result = this.actual.call(context);
          } catch (e) {
            exception = e;
          }
          this.message = function() {
            var msg;
            msg = "Then clause" + (n > 1 ? " #" + n : "") + " [";
            msg += this.actual.toString();
            msg += "] failed by ";
            if (exception) {
              msg += "throwing: " + exception.toString();
            } else {
              msg += "returning false";
            }
            return msg;
          };
          return result === false;
        }
      });
    });
    window.When = window.Given = function() {
      var assignResultTo, mostRecentlyUsed, setupFunction;
      setupFunction = o(arguments).firstThat(function(arg) {
        return o(arg).isFunction();
      });
      assignResultTo = o(arguments).firstThat(function(arg) {
        return o(arg).isString();
      });
      mostRecentlyUsed = window.Given;
      return beforeEach(function() {
        var context, result;
        context = jasmine.getEnv().currentSpec;
        result = setupFunction.call(context);
        if (assignResultTo) {
          if (!context[assignResultTo]) {
            return context[assignResultTo] = result;
          } else {
            throw new Error("Unfortunately, the variable '" + assignResultTo + "' is already assigned to: " + context[assignResultTo]);
          }
        }
      });
    };
    window.Then = function(expectationFunction) {
      var chainableThen, expectations, mostRecentlyUsed, self, subsequentThen;
      mostRecentlyUsed = window.Then;
      self = this;
      expectations = [expectationFunction];
      subsequentThen = function(additionalExpectation) {
        expectations.push(additionalExpectation);
        return this;
      };
      chainableThen = {
        Then: subsequentThen,
        And: subsequentThen
      };
      it("then", function() {
        var i, _results;
        i = 0;
        _results = [];
        while (i < expectations.length) {
          expect(expectations[i]).not.toHaveReturnedFalseFromThen(jasmine.getEnv().currentSpec, i + 1);
          _results.push(i++);
        }
        return _results;
      });
      return chainableThen;
    };
    mostRecentlyUsed = window.Given;
    window.And = function() {
      return mostRecentlyUsed.apply(this, jasmine.util.argsToArray(arguments));
    };
    return o = function(thing) {
      return {
        isFunction: function() {
          return Object.prototype.toString.call(thing) === "[object Function]";
        },
        isString: function() {
          return Object.prototype.toString.call(thing) === "[object String]";
        },
        firstThat: function(test) {
          var i;
          i = 0;
          while (i < thing.length) {
            if (test(thing[i]) === true) return thing[i];
            i++;
          }
        }
      };
    };
  })(jasmine);

}).call(this);
