grunt = require("grunt")

describe "Basic Given-When-Then usage", ->

  describe "passing tests", ->
    invariants.passingSpec()

    Given -> createSpec """
      describe 'foo', ->
        Given -> @foo = 1
        When -> @foo++
        Then -> @foo == 2
    """
    WhenIRunTheSpec()
    Then -> expect(@result.output).toMatch(/ok.*- foo then this.foo === 2/)
