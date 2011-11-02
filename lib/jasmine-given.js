//https://github.com/searls/jasmine-given
(function(jasmine) {
  beforeEach(function() {
    this.addMatchers({
      toHaveReturnedFalseFromThen: function(n) {
        this.message = function() {
          return "Then"+(n > 1 ? " #"+n : "")+" failed by returning false";
        };
        return this.actual === false;
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
        expect(expectations[i].call(self)).not.toHaveReturnedFalseFromThen(i+1);
      };
    });
    return chainableThen;
  };

  var mostRecentlyUsed = window.Given;
  window.And = function() {
    return mostRecentlyUsed.apply(this,jasmine.util.argsToArray(arguments));
  };

})(jasmine);