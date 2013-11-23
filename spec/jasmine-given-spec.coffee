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
      Then -> timesWhenWasInvoked == 2
      Then -> timesGivenWasInvoked == 3
      Then "it's important this gets invoked separately for each spec", -> timesWhenWasInvoked == 4

    context "using And statements", ->
      timesGivenWasInvoked = timesWhenWasInvoked = 0
      Given -> timesGivenWasInvoked++
      When -> timesWhenWasInvoked++
      Then -> timesGivenWasInvoked == 1
      And -> timesWhenWasInvoked == 1
      And -> timesGivenWasInvoked == 1
      And -> timesWhenWasInvoked == 1

    context "chaining Then statements", ->
      timesGivenWasInvoked = timesWhenWasInvoked = 0
      Given -> timesGivenWasInvoked++
      When -> timesWhenWasInvoked++
      Then(-> timesGivenWasInvoked == 1)
      .And(-> timesWhenWasInvoked == 1)
      .And(-> timesGivenWasInvoked == 1)
      .And(-> timesWhenWasInvoked == 1)
      Then -> timesWhenWasInvoked == 2

  describe "Invariant", ->
    context "implicitly called for each Then", ->
      timesInvariantWasInvoked = 0
      Invariant -> timesInvariantWasInvoked++
      Then -> timesInvariantWasInvoked == 1
      Then -> timesInvariantWasInvoked == 2

    context "following a Then", ->
      Invariant -> expect(@meat).toContain('pork')
      Given -> @meat = 'pork'
      When -> @meat += 'muffin'
      Then -> @meat == 'porkmuffin'
      And -> @meat != 'hammuffin'

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

  describe "Givens before Whens order", ->
      context "Outer block", ->
          Given ->  @a = 1
          Given ->  @b = 2
          When -> @sum = @a + @b
          Then -> @sum == 3

          context "Middle block", ->
            Given -> @units = "days"
            When -> @label = "#{@sum} #{@units}"
            Then -> @label == "3 days"

            context "Inner block A", ->
                Given -> @a = -2
                Then -> @label == "0 days"

            context "Inner block B", ->
                Given -> @units = "cm"
                Then -> @label == "3 cm"

