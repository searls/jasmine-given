# jasmine-given

[![Build Status](https://secure.travis-ci.org/searls/jasmine-given.png)](http://travis-ci.org/searls/jasmine-given)

jasmine-given is a [Jasmine](https://github.com/pivotal/jasmine) helper that encourages leaner, meaner specs using `Given`, `When`, and `Then`. It is a shameless tribute to Jim Weirich's terrific [rspec-given](https://github.com/jimweirich/rspec-given) gem.

**[Download the latest version here](https://raw.github.com/searls/jasmine-given/master/dist/jasmine-given.js)**.

The basic idea behind the "*-given" meme is a humble acknowledgement of given-when-then as the best English language analogue we have to arrange-act-assert. With rspec and jasmine, we often approximate "given-when-then" with "let-beforeEach-it" (noting that jasmine lacks `let`).

The big idea is "why approximate given-when-then, when we could actually just use them?"

The small idea is "if we couldn't write English along with our `it` blocks then we'd be encouraged to write cleaner, clearer matchers to articulate our expectations."

Both ideas are pretty cool. Thanks, Jim!

## Example (CoffeeScript)

Oh, and jasmine-given looks *much* nicer in CoffeeScript, so I'll show that example first:

``` coffeescript
describe "assigning stuff to this", ->
  Given -> @number = 24
  Given -> @number++
  When -> @number *= 2
  Then -> @number == 50
  # or
  Then -> expect(@number).toBe(50)

describe "assigning stuff to variables", ->
  subject=null
  Given -> subject = []
  When -> subject.push('foo')
  Then -> subject.length == 1
  # or
  Then -> expect(subject.length).toBe(1)
```

As you might infer from the above, `Then` will trigger a spec failure when the function passed to it returns `false`. As shown above, traditional expectations can still be used, but using simple booleans can make for significantly easier-to-read expectations when you're asserting something as obvious as equality.

## Example (JavaScript)

Of course, jasmine-given also works fine in JavaScript; but as you can see, it's exceptionally clunky in comparison:

``` javascript
describe("assigning stuff to this", function() {
  Given(function() { this.number = 24; });
  Given(function() { this.number++; });
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
```

## Supporting Idempotent "Then" statements

Jim mentioned to me that `Then` blocks ought to be idempotent (that is, since they're assertions they should not have any affect on the state of the subject being specified). As a result, one optimization that rspec-given might make would be to execute **n** `Then` expectations without executing each `Then`'s depended-on `Given` and `When` blocks **n** times.

Take this example from jasmine-given's spec:

``` coffeescript
describe "eliminating redundant test execution", ->
  context "a traditional spec with numerous Then statements", ->
    timesGivenWasInvoked = timesWhenWasInvoked = 0
    Given -> timesGivenWasInvoked++
    When -> timesWhenWasInvoked++
    Then -> timesGivenWasInvoked == 1
    Then -> timesWhenWasInvoked == 2
    Then -> timesGivenWasInvoked == 3
    Then -> timesWhenWasInvoked == 4
```
Because there are four `Then` statements, the `Given` and `When` are each executed four times. That's because it would be unreasonable for Jasmine to expect each `it` function  to be idempotent.

However, spec authors can leverage idempotence safely when writing in a given-when-then format. You opt-in with jasmine-given by using `And` blocks, as shown below:

``` coffeescript
  context "chaining Then statements", ->
    timesGivenWasInvoked = timesWhenWasInvoked = 0
    Given -> timesGivenWasInvoked++
    When -> timesWhenWasInvoked++

    Then -> timesGivenWasInvoked == 1
    And -> timesWhenWasInvoked == 1
    And -> timesGivenWasInvoked == 1
    And -> timesWhenWasInvoked == 1

    Then -> timesWhenWasInvoked == 2
```

In this example, `Given` and `When` are only invoked one time each for the first `Then, because jasmine-given rolled all of those `Then` & `And` statements up into a single `it` in Jasmine.  Note that the label of the `it` is taken from the `Then` only.

Leveraging this feature is likely to have the effect of speeding up your specs, especially if your specs are otherwise slow (integration specs or DOM-heavy).

The above spec can also be expressed in JavaScript:

``` javascript

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

  context("chaining Then statements", function() {
    var timesGivenWasInvoked = 0,
        timesWhenWasInvoked = 0;
    Given(function() { timesGivenWasInvoked++; });
    When(function() { timesWhenWasInvoked++; });
    Then(function() { return timesGivenWasInvoked == 1; })
    And(function() { return timesWhenWasInvoked == 1; })
    And(function() { return timesGivenWasInvoked == 1; })
    And(function() { return timesWhenWasInvoked == 1; })
  });
});

```
