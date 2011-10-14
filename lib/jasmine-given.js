//https://github.com/searls/jasmine-given
(function(jasmine) {
  beforeEach(function() {
    this.addMatchers({
      toHaveReturnedFalseFromThen: function() {
        this.message = function() { return "Then() returned false"; };
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
    it("then", function() {
      expect(expectationFunction()).not.toHaveReturnedFalseFromThen();
    });
  };

})(jasmine);