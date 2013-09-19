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


  describe 'a failing Invariant will fail a test', ->
    Invariant -> false
    describe 'nested thing', ->
      Then -> jasmine.getEnv().currentSpec.results.failedCount == 1
      And -> jasmine.getEnv().currentSpec.results_ = new jasmine.NestedResults()

  describe "support for jasmine-only style `Then.only` blocks", ->
    Given -> @expectationFunction = jasmine.createSpy('my expectation')
    Given -> spyOn(it, 'only')
    When -> Then.only(@expectationFunction)
    Then -> expect(it.only).toHaveBeenCalledWith jasmine.any(String), jasmine.argThat (arg) =>
      arg()
      @expectationFunction.calls.length == 1


  describe "support for done() style blocks", ->
    describe "Then blocks", ->
      Given -> spyOn(window, 'it')

      context "no-arg", ->
        When -> Then ->
        Then -> expect(it).toHaveBeenCalledWith jasmine.any(String), jasmine.argThat (func) =>
          func.length == 0

      context "done-ful", ->
        When -> Then (done) ->
        Then -> expect(it).toHaveBeenCalledWith jasmine.any(String), jasmine.argThat (func) =>
          func.length == 1

    describe "Given blocks", ->
      Given -> spyOn(window, 'beforeEach')

      context "no-arg", ->
        When -> Given ->
        Then -> expect(beforeEach).toHaveBeenCalledWith jasmine.argThat (func) =>
          func.length == 0

      context "done-ful", ->
        When -> Given (done) ->
        Then -> expect(beforeEach).toHaveBeenCalledWith jasmine.argThat (func) =>
          func.length == 1


  describe "matchers", ->
    Given -> @subject = jasmine._given.matchers
    describe "toHaveReturnedFalseFromThen", ->
      When -> @result = @subject.toHaveReturnedFalseFromThen.call(@context, @, 1)

      describe "super simple uses", ->
        context "simple failing matcher", ->
          Given -> @context = actual: -> false
          Then -> expect(@context.message()).toEqual('Then clause `false` failed by returning false')


        context "a matcher that blows up", ->
          Given -> @context = actual: -> throw "Whoops"
          Then -> expect(@context.message()).toEqual('Then clause `throw "Whoops"` failed by throwing: Whoops')

      describe "obfuscated by variables", ->
        Given -> @context = actual: -> @a() == @b

        context "simple threequals matcher", ->
          Given -> @a = -> 1
          Given -> @b = 3
          Then -> expect(@context.message()).toEqual('Then clause `this.a() === this.b` failed by returning false')

        context "a matcher that blows up", ->
          Given -> @a = -> throw 'Whoops'
          Given -> @b = 3
          Then -> expect(@context.message()).toEqual('Then clause `this.a() === this.b` failed by throwing: Whoops')
