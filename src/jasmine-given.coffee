((jasmine) ->
  beforeEach ->
    @addMatchers toHaveReturnedFalseFromThen: (context, n) ->
      result = false
      exception = undefined
      try
        result = @actual.call(context)
      catch e
        exception = e
      @message = ->
        msg = "Then clause #{if n > 1 then " ##{n}" else ""} [#{@actual.toString()}] failed by "
        if exception
          msg += "throwing: " + exception.toString()
        else
          msg += "returning false"
        msg

      result is false

  window.When = window.Given = ->
    setupFunction = o(arguments).firstThat (arg) -> o(arg).isFunction()
    assignResultTo = o(arguments).firstThat (arg) -> o(arg).isString()
    mostRecentlyUsed = window.Given
    beforeEach ->
      context = jasmine.getEnv().currentSpec
      result = setupFunction.call(context)
      if assignResultTo
        unless context[assignResultTo]
          context[assignResultTo] = result
        else
          throw new Error("Unfortunately, the variable '#{assignResultTo}' is already assigned to: #{context[assignResultTo]}")

  window.Then = (expectationFunction) ->
    mostRecentlyUsed = window.Then
    expectations = [ expectationFunction ]
    subsequentThen = (additionalExpectation) ->
      expectations.push additionalExpectation
      this

    it "then", ->
      i = 0
      while i < expectations.length
        expect(expectations[i]).not.toHaveReturnedFalseFromThen jasmine.getEnv().currentSpec, i + 1
        i++

    Then: subsequentThen, And: subsequentThen

  mostRecentlyUsed = window.Given
  window.And = ->
    mostRecentlyUsed.apply this, jasmine.util.argsToArray(arguments)

  o = (thing) ->
    isFunction: ->
      Object::toString.call(thing) is "[object Function]"

    isString: ->
      Object::toString.call(thing) is "[object String]"

    firstThat: (test) ->
      i = 0
      while i < thing.length
        return thing[i]  if test(thing[i]) is true
        i++
      return undefined

) jasmine