//https://github.com/searls/jasmine-given
(function(jasmine) {
  beforeEach(function() {
    this.addMatchers({
      toHaveReturnedFalseFromThen: function(context,n) {
        var result = false,
            exception;

        try {
          result = this.actual.call(context)
        } catch(e) {
          exception = e
        }

        this.message = function() {
          var msg = "Then clause"+(n > 1 ? " #"+n : "")+" [";
          msg += this.actual.toString();
          msg += "] failed by ";
          if(exception) {
            msg += "throwing: "+exception.toString();
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
    var setupFunction = o(arguments).firstThat(function(arg) {
      return o(arg).isFunction();
    });
    var assignResultTo = o(arguments).firstThat(function(arg) {
      return o(arg).isString();
    });

    mostRecentlyUsed = window.Given;
    beforeEach(function() {
      var context = jasmine.getEnv().currentSpec,
          result = setupFunction.call(context);
      if(assignResultTo) {
        if(!context[assignResultTo]) {
          context[assignResultTo] = result;
        } else {
          throw new Error("Unfortunately, the variable '"+assignResultTo+
                          "' is already assigned to: "+context[assignResultTo]);
        }
      }
    });
  };

  window.Then = function(expectationFunction) {
    mostRecentlyUsed = window.Then;
    var self = this,
        expectations = [expectationFunction],
        subsequentThen = function(additionalExpectation) {
          expectations.push(additionalExpectation)
          return this;
        },
        chainableThen = {
          Then: subsequentThen,
          And: subsequentThen
        };

    it("then", function() {
      for (var i=0; i < expectations.length; i++) {
        expect(expectations[i]).not.toHaveReturnedFalseFromThen(jasmine.getEnv().currentSpec,i+1);
      };
    });
    return chainableThen;
  };

  var mostRecentlyUsed = window.Given;
  window.And = function() {
    return mostRecentlyUsed.apply(this,jasmine.util.argsToArray(arguments));
  };

  var o = function(thing){
    return {
      isFunction: function() {
        return Object.prototype.toString.call(thing) == '[object Function]';
      },
      isString: function() {
        return Object.prototype.toString.call(thing) == '[object String]';
      },
      firstThat: function(test) {
        for(var i=0;i<thing.length;i++) {
          if(test(thing[i]) === true) {
            return thing[i];
          }
        }
      }
    };
  };

})(jasmine);