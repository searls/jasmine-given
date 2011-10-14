describe("jasmine-given api", function() {
  describe("assigning stuff to this", function() {
    Given(function() { this.number = 24; });
    When(function() { this.number *= 2; });
    Then(function() { return this.number === 48; });
    Then(function() { expect(this.number).toBe(48) });
  });

  describe("assigning stuff to variables", function() {
    var subject;
    Given(function() { subject = []; });
    When(function() { subject.push('foo'); });
    Then(function() { return subject.length === 1; });
    Then(function() { expect(subject.length).toBe(1); });
  });
});
