# jasmine-given

jasmine-given is a [Jasmine](https://github.com/pivotal/jasmine) helper that encourages leaner, meaner specs using `Given`, `When`, and `Then`. It is a shameless tribute to Jim Weirich's terrific [rspec-given](https://github.com/jimweirich/rspec-given) gem.

**[Download the latest version here](https://github.com/searls/jasmine-given/archives/master)**.

The basic idea behind the "*-given" meme is a humble acknowledgement of given-when-then as the best English language analogue we have to arrange-act-assert. With rspec and jasmine, we often approximate "given-when-then" with "let-beforeEach-it" (noting that jasmine lacks `let`).

The big idea is "why approximate given-when-then, when we could actually just use them?"

The small idea is "if we couldn't write English along with our `it` blocks then we'd be encouraged to write cleaner, clearer matchers to articulate our expectations."

Both ideas are pretty cool. Thanks, Jim!

## Example (CoffeeScript)

Oh, and jasmine-given looks *much* nicer in CoffeeScript, so I'll show that example first:

``` coffeescript

describe "assigning stuff to this", ->
  Given -> @number = 24
  When -> @number *= 2
  Then -> @number == 48
  # -or-
  Then -> expect(@number).toBe(48)

describe "assigning stuff to variables", ->
  subject=null
  Given -> subject = []
  When -> subject.push('foo')
  Then -> subject.length == 1
  # -or-
  Then -> expect(subject.length).toBe(1)
```

As you might infer from the above, `Then` will trigger a spec failure when the function passed to it returns `false`. As shown above, traditional expectations can still be used, but using simple booleans can make for significantly easier-to-read expectations when you're asserting something as obvious as equality.

## Example (JavaScript)

Of course, jasmine-given also works fine in JavaScript; but as you can see, it's exceptionally clunky in comparison:

``` javascript
describe("assigning stuff to this", function() {
  Given(function() { this.number = 24; });
  When(function() { this.number *= 2; });
  Then(function() { return this.number === 48; });
  // -or- 
  Then(function() { expect(this.number).toBe(48) });
});

describe("assigning stuff to variables", function() {
  var subject;
  Given(function() { subject = []; });
  When(function() { subject.push('foo'); });
  Then(function() { return subject.length === 1; });
  // -or-
  Then(function() { expect(subject.length).toBe(1); });
});
```