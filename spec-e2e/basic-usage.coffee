grunt = require("grunt")

describe "Basic Given-When-Then usage", ->

  describe "passing tests", ->
    invariants.passingSpec()

    describe "GWT", ->
        Given -> createSpec """
          describe 'foo', ->
            Given -> @foo = 1
            When -> @foo++
            Then -> @foo == 2
        """
        WhenIRunTheSpec()
        Then -> expect(@result.output).toMatch(/ok.*- foo then this.foo === 2/)

    describe "And", ->
      Given -> createSpec """
        describe '', ->
          Given -> @things = []
          And -> @things.push(1)
          When -> @things.push(2)
          And -> @things.reverse()
          Then -> @things.length == 2
          And -> @things[0] == 2
      """
      WhenIRunTheSpec()
      Then -> expect(@result.output).toContain("then this.things.length === 2")
      And -> expect(@result.output).toContain("# tests 1")

    describe "Givens before Whens", ->
      Given -> createSpec """
        describe '', ->
          When -> @result = 3 + @number

          describe '1', ->
            Given -> @number = 1
            Then -> @result == 4

          describe '2', ->
            Given -> @number = 2
            Then -> @result == 5
      """
      WhenIRunTheSpec()
      Then -> expect(@result.output).toContain("1 then this.result === 4")
      And -> expect(@result.output).toContain("2 then this.result === 5")

    describe "Invariants", ->
      Given -> createSpec """
        describe '', ->
          Invariant -> @foo ||= 0
          Invariant -> @foo++

          describe '1', ->
            Then -> @foo == 1

          describe '2', ->
            Invariant -> @foo++
            Then -> @foo == 2
      """
      WhenIRunTheSpec()
      Then -> expect(@result.output).toContain("1 then this.foo === 1")
      And -> expect(@result.output).toContain("2 then this.foo === 2")


