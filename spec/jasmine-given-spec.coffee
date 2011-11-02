describe "jasmine-given CoffeeScript API", ->
  describe "assigning stuff to this", ->
    Given -> @number = 24
    And -> @number++
    When -> @number *= 2
    Then -> @number == 50
    And -> expect(@number).toBe(50)

  describe "assigning stuff to variables", ->
    subject=null
    Given -> subject = []
    When -> subject.push('foo')
    Then -> subject.length == 1
    And -> expect(subject.length).toBe(1)

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


describe "jasmine-given implementation", ->
  describe "returning boolean values from Then", ->
    passed=null
    beforeEach ->
      this.addMatchers
        toHaveReturnedFalseFromThen: ->
          passed = !this.actual
          false

    context "a true is returned", ->
      Then -> 1 + 1 == 2
      it "passed", ->
        expect(passed).toBe(false)

    context "a false is returned", ->
      Then -> 1 + 1 == 3
      it "failed", ->
        expect(passed).toBe(true)


