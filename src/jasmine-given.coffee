###
jasmine-given @@VERSION@@
Adds a Given-When-Then DSL to jasmine as an alternative style for specs
site: https://github.com/searls/jasmine-given
###
((jasmine) ->

  mostRecentlyUsed = null

  stringifyExpectation = (expectation) ->
    matches = expectation.toString().replace(/\n/g,'').match(/function\s?\(\)\s?{\s*(return\s+)?(.*?)(;)?\s*}/i)
    if matches and matches.length >= 3 then matches[2] else ""

  beforeEach ->
    @addMatchers toHaveReturnedFalseFromThen: (context, n) ->
      result = false
      exception = undefined
      try
        result = @actual.call(context)
      catch e
        exception = e
      @message = ->
        msg = "Then clause #{if n > 1 then " ##{n}" else ""} `#{stringifyExpectation(@actual)}` failed by "
        if exception
          msg += "throwing: " + exception.toString()
        else
          msg += "returning false"
        msg

      result is false
  root = @

  root.When = root.Given = ->
    setupFunction = o(arguments).firstThat (arg) -> o(arg).isFunction()
    assignResultTo = o(arguments).firstThat (arg) -> o(arg).isString()
    mostRecentlyUsed = root.Given
    beforeEach ->
      context = jasmine.getEnv().currentSpec
      result = setupFunction.call(context)
      if assignResultTo
        unless context[assignResultTo]
          context[assignResultTo] = result
        else
          throw new Error("Unfortunately, the variable '#{assignResultTo}' is already assigned to: #{context[assignResultTo]}")

  mostRecentExpectations = null

  root.Then = (expectationFunction) ->
    mostRecentlyUsed = root.subsequentThen
    mostRecentExpectations = expectations = [ expectationFunction ]

    it "then #{stringifyExpectation(expectations)}", ->
      i = 0
      while i < expectations.length
        expect(expectations[i]).not.toHaveReturnedFalseFromThen jasmine.getEnv().currentSpec, i + 1
        i++

    Then: subsequentThen, And: subsequentThen

  root.subsequentThen = (additionalExpectation) ->
    mostRecentExpectations.push additionalExpectation
    this

  mostRecentlyUsed = root.Given
  root.And = ->
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
