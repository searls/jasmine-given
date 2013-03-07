describe("jasmine-given JavaScript API", function() {
  describe("assigning stuff to this", function() {
    Given(function() { this.number = 24; });
    And(function() { this.number++; });
    When(function() { this.number *= 2; });
    Then(function() { return this.number === 50; });
    // or
    Then(function() { expect(this.number).toBe(50) });
  });

  describe("assigning stuff to variables", function() {
    var subject;
    Given(function() { subject = []; });
    When(function() { subject.push('foo'); });
    Then(function() { return subject.length === 1; });
    // or
    Then(function() { expect(subject.length).toBe(1); });
  });

  describe("eliminating redundant test execution", function() {
    context("a traditional spec with numerous Then statements", function() {
      var timesGivenWasInvoked = 0,
          timesWhenWasInvoked = 0;
      Given(function() { timesGivenWasInvoked++; });
      When(function() { timesWhenWasInvoked++; });
      Then(function() { return timesGivenWasInvoked == 1; });
      Then(function() { return timesWhenWasInvoked == 2; });
      Then(function() { return timesGivenWasInvoked == 3; });
      Then(function() { return timesWhenWasInvoked == 4; });
    });

    context("using And statements", function() {
      var timesGivenWasInvoked = 0,
          timesWhenWasInvoked = 0;
      Given(function() { timesGivenWasInvoked++; });
      When(function() { timesWhenWasInvoked++; });
      Then(function() { return timesGivenWasInvoked == 1; });
      And(function() { return timesWhenWasInvoked == 1; });
      And(function() { return timesGivenWasInvoked == 1; });
      And(function() { return timesWhenWasInvoked == 1; });
      Then(function() { return timesWhenWasInvoked == 2; })
    });

    context("chaining Then statements", function() {
      var timesGivenWasInvoked = 0,
          timesWhenWasInvoked = 0;
      Given(function() { timesGivenWasInvoked++; });
      When(function() { timesWhenWasInvoked++; });
      Then(function() { return timesGivenWasInvoked == 1; })
      .And(function() { return timesWhenWasInvoked == 1; })
      .And(function() { return timesGivenWasInvoked == 1; })
      .And(function() { return timesWhenWasInvoked == 1; })
      Then(function() { return timesWhenWasInvoked == 2; })
    });
  });

});
