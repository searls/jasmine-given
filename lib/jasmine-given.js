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
    beforeEach(function() {
      setupFunction();
    });
  };

  window.Then = function(expectationFunction) {
    var self = this,
        expectations = [expectationFunction],
        chainableThen = {
          Then: function(additionalExpectation) {
            expectations.push(additionalExpectation)
            return this;
          }
        };

    it("then", function() {
      for (var i=0; i < expectations.length; i++) {
        expect(expectations[i].call(self)).not.toHaveReturnedFalseFromThen(i+1);
      };
    });
    return chainableThen;
  };

})(jasmine);