[![Build Status](https://secure.travis-ci.org/searls/jasmine-given.png)](http://travis-ci.org/searls/jasmine-given)

## 2.x series

We just released a version 2.0.0, thanks to the contributions of [@ronen](https://github.com/ronen), to bring jasmine-given closer to parity with rspec-given. In particular, jasmine-given will now:

* ensure that `Given` statements [will *always* execute before](#execution-order-givens-then-whens-then-thens) any `When` statements. This is counter-intuitive at first, but can really help you DRY up specs that require variable setup.
* [allow users to use `And` in place of multiple `Then` statements](#supporting-idempotent-then-statements); when using `And` following a `Then`, the set-up will only be executed for the first `Then`, which could be a significant speed-up depending on the test while looking cleaner than chaining `Then` statements with parentheses.

Keep in mind that the former will be a **breaking change** for many test suites that currently use jasmine-given, so be sure to allot yourself some time to address any test failures that occur because a `Given` was incidentally placed after a `When` in a way that doesn't agree with the new execution order.

# jasmine-given

jasmine-given is a [Jasmine](https://github.com/pivotal/jasmine) helper that encourages leaner, meaner specs using `Given`, `When`, and `Then`. It is a shameless tribute to Jim Weirich's terrific [rspec-given](https://github.com/jimweirich/rspec-given) gem.

**[Download the latest version here](https://raw.github.com/searls/jasmine-given/master/dist/jasmine-given.js)**.

The basic idea behind the "*-given" meme is a humble acknowledgement of given-when-then as the best English language analogue we have to arrange-act-assert. With rspec and jasmine, we often approximate "given-when-then" with "let-beforeEach-it" (noting that jasmine lacks `let`).

The big idea is "why approximate given-when-then, when we could actually just use them?"

The small idea is "if we couldn't write English along with our `it` blocks then we'd be encouraged to write cleaner, clearer matchers to articulate our expectations."

The subtle idea is that all "given"s should be evaluated before the "when"s.  This can DRY up your specs: you don't need to repeat a series of "when"s in order to test the final result with different initial "given"s.

All ideas are pretty cool. Thanks, Jim!

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

## Execution order: Givens then Whens then Thens

The execution order for executing a `Then` is to execute all preceding `Given` blocks
from the outside in, and next all the preceeding `When` blocks from the outside in, and
then the `Then`.  This means that a later `Given` can affect an earlier `When`!
While this may seem odd at first glance, it can DRY up your specs, especially if
you are testing a series of `When` steps whose final outcome depends on an
initial condition.  For example:

```
    Given -> user
    When -> login user

    describe "clicking create", ->

        When -> createButton.click()
        Then -> expect(ajax).toHaveBeenCalled()

        describe "creation succeeds", ->
            When -> ajax.success()
            Then -> object_is_shown()

            describe "reports success message", ->
                Then -> feedback_message.hasContents "created"

            describe "novice gets congratulations message", ->
                Given -> user.isNovice = true
                Then -> feedback_message.hasContents "congratulations!"

            describe "expert gets no feedback", ->
                Given -> user.isExpert = true
                Then -> feedback_message.isEmpty()
```
For the final three `Then`s, the exeuction order is:

```
       Given -> user
       When -> login user
       When -> createButton.click()
       When -> ajax.success()
       Then -> feedback_message.hasContents "created"

       Given -> user
       Given -> user.isNovice = true
       When -> login user
       When -> createButton.click()
       When -> ajax.success()
       Then -> feedback_message.hasContents "congratulations!"

       Given -> user
       Given -> user.isExpert = true
       When -> login user
       When -> createButton.click()
       When -> ajax.success()
       Then -> feedback_message.isEmpty()
```
Without this `Given`/`When` execution order, the only straightforward way to get the above
behavior would be to duplicate then `When`s for each user case.

## Supporting Idempotent "Then" statements

Jim mentioned to me that `Then` blocks ought to be idempotent (that is, since they're assertions they should not have any affect on the state of the subject being specified). As a result, one improvement he made to rspec-given 2.x was the `And` method, which—by following a `Then`—would be like invoked **n** `Then` expectations without executing each `Then`'s depended-on `Given` and `When` blocks **n** times.

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

In this example, `Given` and `When` are only invoked one time each for the first `Then`, because jasmine-given rolled all of those `Then` & `And` statements up into a single `it` in Jasmine.  Note that the label of the `it` is taken from the `Then` only.

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

# "it"-style test labels

Jasmine-given labels your underlying `it` blocks with the source expression itself, encouraging writing cleaner, clearer matchers -- and more DRY than saying the same thing twice, once in code and once in English.  But there are times when we're using third-party libraries or matchers that just don't read cleanly as English, even when they're expressing a simple concept.

Or, perhaps you are using a collection of `Then` and `And` statements to express a single specification.  So, when needed, you *may* use a label for your `Then` statements:

        Then "makes AJAX POST request to create item", -> expect(@ajax_spy).toHaveBeenCalled()
        And -> @ajax_spy.mostRecentCall.args[0].type = 'POST'
        And -> @ajax_spy.mostRecentCall.args[0].url == "/items"
        And -> @ajax_spy.mostRecentCall.args[0].data.item.user_id == userID
        And -> @ajax_spy.mostRecentCall.args[0].data.item.name == itemName
