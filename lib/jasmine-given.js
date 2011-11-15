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

  window.When = window.Given = function(setupFunction) {
    mostRecentlyUsed = window.Given;
    beforeEach(function() {
      setupFunction();
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
        expect(expectations[i]).not.toHaveReturnedFalseFromThen(self,i+1);
      };
    });
    return chainableThen;
  };

  var mostRecentlyUsed = window.Given;
  window.And = function() {
    return mostRecentlyUsed.apply(this,jasmine.util.argsToArray(arguments));
  };

})(jasmine);