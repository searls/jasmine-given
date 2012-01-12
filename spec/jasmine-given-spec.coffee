describe "jasmine-given CoffeeScript API", ->
  describe "assigning stuff to this", ->
    Given -> @number = 24
    And -> @number++
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

  describe "eliminating redundant test execution", ->
    context "a traditional spec with numerous Then statements", ->
      timesGivenWasInvoked = timesWhenWasInvoked = 0
      Given -> timesGivenWasInvoked++
      When -> timesWhenWasInvoked++
      Then -> timesGivenWasInvoked == 1
      And -> timesWhenWasInvoked == 2
      And -> timesGivenWasInvoked == 3
      And -> timesWhenWasInvoked == 4

    context "chaining Then statements", ->
      timesGivenWasInvoked = timesWhenWasInvoked = 0
      Given -> timesGivenWasInvoked++
      When -> timesWhenWasInvoked++
      Then(-> timesGivenWasInvoked == 1)
      .And(-> timesWhenWasInvoked == 1)
      .And(-> timesGivenWasInvoked == 1)
      .And(-> timesWhenWasInvoked == 1)
      And -> timesWhenWasInvoked == 2

  describe "And", ->
    context "following a Given", ->
      Given -> @a = 'a'
      And -> @b = 'b' == @a #is okay to return false
      Then -> @b == false

    context "following a Then", ->
      Given -> @meat = 'pork'
      When -> @meat += 'muffin'
      Then -> @meat == 'porkmuffin'
      And -> @meat != 'hammuffin'


  describe "giving Given a variable", ->
    context "add a variable to `this`", ->
      Given "pizza", -> 5
      Then -> @pizza == 5

    context "a variable of that name already exists on `this`", ->
      Given -> @muffin = 1
      Given -> spyOn(window, "beforeEach").andCallFake (f) -> f()
      Then -> expect(-> Given "muffin", -> 2).toThrow(
        "Unfortunately, the variable 'muffin' is already assigned to: 1")

    context "a subsequent unrelated test run", ->
      Then -> @pizza == undefined

describe "jasmine-given implementation", ->
  describe "returning boolean values from Then", ->
    describe "Then()'s responsibility", ->
      passed=null
      beforeEach ->
        this.addMatchers
          toHaveReturnedFalseFromThen: (ctx) ->
            passed = !this.actual.call(ctx)
            false

      context "a true is returned", ->
        Then -> 1 + 1 == 2
        it "passed", ->
          expect(passed).toBe(false)

      context "a false is returned", ->
        Then -> 1 + 1 == 3
        it "failed", ->
          expect(passed).toBe(true)


