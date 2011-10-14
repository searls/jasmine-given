describe "jasmine-given api", ->
  describe "assigning stuff to this", ->
    Given -> @number = 24
    When -> @number *= 2
    Then -> @number == 48
    Then -> expect(@number).toBe(48)

  describe "assigning stuff to variables", ->
    subject=null
    Given -> subject = []
    When -> subject.push('foo')
    Then -> subject.length == 1
    Then -> expect(subject.length).toBe(1)



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


