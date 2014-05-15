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
    Given -> it.only ||= ->
    Given -> spyOn(it, 'only')
    When -> Then.only(@expectationFunction)
    Then -> expect(it.only.calls[0].args[0]).toEqual(jasmine.any(String))
    And ->
      it.only.calls[0].args[1].call()
      @expectationFunction.calls.length == 1

  describe "support for async done() style blocks", ->
    describe "Then blocks", ->
      beforeEach ->
        spyOn(window, 'it')
        spyOn(window, 'beforeEach').andCallFake (f) -> f()

        @afterEaches = []
        spyOn(window, 'afterEach').andCallFake (f) =>
          @afterEaches.push(f)

      afterEach ->
        afterEachAction() for afterEachAction in @afterEaches

      describe "Then", ->
        beforeEach ->
          Then (done) ->
        it '', ->
          expect(it.calls[0].args[0]).toEqual(jasmine.any(String))
          expect(it.calls[0].args[1].length).toEqual(1)

      describe "When", ->
        beforeEach ->
          @then = jasmine.createSpy("Then")

        context "the when does not call its done()", ->
          beforeEach ->
            When (done) ->
            Then (done) -> @then(); done()
          it '', ->
            specImplementation = it.calls[0].args[1]
            doneProvidedByJasmineRunner = jasmine.createSpy("done")
            specImplementation(doneProvidedByJasmineRunner)
            expect(@then).not.toHaveBeenCalled()
            expect(doneProvidedByJasmineRunner).not.toHaveBeenCalled()

        context "the when does indeed call its done()", ->
          beforeEach ->
            When (done) -> done()
            Then (done) -> @then(); done()
          it '', ->
            specImplementation = it.calls[0].args[1]
            doneProvidedByJasmineRunner = jasmine.createSpy("done")
            specImplementation(doneProvidedByJasmineRunner)
            expect(@then).toHaveBeenCalled()
            expect(doneProvidedByJasmineRunner).toHaveBeenCalled()

        context "has a boatload of commands", ->
          beforeEach ->
            @callCount = 0

            inc = (done) =>
              @callCount++
              done?()

            Invariant (done) -> inc(done)
            Invariant -> inc()
            When (done) -> inc(done)
            And -> inc()
            Then (done) -> inc(done)
            And -> inc()
            And (done) -> inc(done)
            And -> inc()

          it '', ->
            specImplementation = it.calls[0].args[1]
            doneProvidedByJasmineRunner = jasmine.createSpy("done")

            specImplementation(doneProvidedByJasmineRunner)

            expect(@callCount).toBe(8)
            expect(doneProvidedByJasmineRunner).toHaveBeenCalled()

    describe "Given blocks", ->
      Given -> spyOn(window, 'beforeEach')

      context "no-arg", ->
        When -> Given ->
        Then -> beforeEach.calls[0].args[0].length == 0

      context "done-ful", ->
        When -> Given (done) ->
        Then -> beforeEach.calls[0].args[0].length == 1

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
          Then -> expect(@context.message()).toEqual """
                                                     Then clause `this.a() === this.b` failed by returning false

                                                     This comparison was detected:
                                                       this.a() === this.b
                                                       1 === 3
                                                     """

        context "two deeply equal but not === things", ->
          Given -> @a = -> [1]
          Given -> @b = [1]
          Then -> expect(@context.message()).toEqual """
                                                     Then clause `this.a() === this.b` failed by returning false

                                                     This comparison was detected:
                                                       this.a() === this.b
                                                       1 === 1

                                                     However, these items are deeply equal! Try an expectation like this instead:
                                                       expect(this.a()).toEqual(this.b)
                                                     """


        context "simple !== matcher", ->
          Given -> @context = actual: -> @a() != @b
          Given -> @a = -> 1
          Given -> @b = 1
          Then -> expect(@context.message()).toEqual """
                                                     Then clause `this.a() !== this.b` failed by returning false

                                                     This comparison was detected:
                                                       this.a() !== this.b
                                                       1 !== 1
                                                     """

        context "a matcher that blows up", ->
          Given -> @a = -> throw 'Whoops'
          Given -> @b = 3
          Then -> expect(@context.message()).toEqual """
                                                     Then clause `this.a() === this.b` failed by throwing: Whoops

                                                     This comparison was detected:
                                                       this.a() === this.b
                                                       <Error: "Whoops"> === 3
                                                     """

        context "a final statement in a multi statement Then", ->
          Given -> @context = actual: ->
            "whatever other stuff in previous statements."
            @a() == @b
          Given -> @a = -> 1
          Given -> @b = 3
          Then -> expect(@context.message()).toEqual """
                                                     Then clause `"whatever other stuff in previous statements."; return this.a() === this.b` failed by returning false

                                                     This comparison was detected:
                                                       this.a() === this.b
                                                       1 === 3
                                                     """

        context "both sides will ReferenceError", ->
          a = ->
          b = 3
          Given -> @context = actual: -> a() == b
          Then -> expect(@context.message()).toEqual("Then clause `a() === b` failed by returning false")
