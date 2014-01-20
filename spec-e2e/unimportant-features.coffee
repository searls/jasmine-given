grunt = require("grunt")

describe "Basic Given-When-Then usage", ->

  When (done) -> runSpec done, (result) ->
    @result = result

  describe "unimportant features", ->
    describe "assigning context properties with strings", ->
      invariants.passingSpec()

      Given -> createSpec """
        describe '', ->
          Given 'pants', -> 5
          When 'shoes', -> 7 + @pants
          Then -> @shoes == 12
      """
      Then -> expect(@result.stdout).toContain("then this.shoes === 12")
