((jasmine) ->

  mostRecentlyUsed = null

  beforeEach ->
    @addMatchers(jasmine._given.matchers)
  root = @

  root.Given = ->
    mostRecentlyUsed = root.Given
    beforeEach getBlock(arguments)

  whenList = []

  root.When = ->
    mostRecentlyUsed = root.When
    b = getBlock(arguments)
    beforeEach ->
      whenList.push(b)
    afterEach ->
      whenList.pop()

  invariantList = []

  root.Invariant = ->
    mostRecentlyUsed = root.Invariant
    invariantBehavior = getBlock(arguments)
    beforeEach ->
      invariantList.push(invariantBehavior)
    afterEach ->
      invariantList.pop()

  getBlock = (thing) ->
    setupFunction = o(thing).firstThat (arg) -> o(arg).isFunction()
    assignResultTo = o(thing).firstThat (arg) -> o(arg).isString()
    doneWrapperFor setupFunction, (done) ->
      context = jasmine.getEnv().currentSpec
      result = setupFunction.call(context, done)
      if assignResultTo
        unless context[assignResultTo]
          context[assignResultTo] = result
        else
          throw new Error("Unfortunately, the variable '#{assignResultTo}' is already assigned to: #{context[assignResultTo]}")

  mostRecentExpectations = null

  declareJasmineSpec = (specArgs, itFunction = it) ->
    label = o(specArgs).firstThat (arg) -> o(arg).isString()
    expectationFunction = o(specArgs).firstThat (arg) -> o(arg).isFunction()
    mostRecentlyUsed = root.subsequentThen
    mostRecentExpectations = expectations = [expectationFunction]

    itFunction "then #{label ? stringifyExpectation(expectations)}", (jasmineDone) ->
      userCommands = [].concat(whenList, invariantList, wrapAsExpectations(expectations))
      new Waterfall(userCommands, jasmineDone).flow()

    return { Then: subsequentThen,  And: subsequentThen }

  wrapAsExpectations = (expectations) ->
    for expectation, i in expectations
      do (expectation, i) ->
        doneWrapperFor expectation, (maybeDone) ->
          expect(expectation).not.toHaveReturnedFalseFromThen(jasmine.getEnv().currentSpec, i + 1, maybeDone)

  doneWrapperFor = (func, toWrap) ->
    if func.length == 0
      -> toWrap()
    else
      (done) -> toWrap(done)


  root.Then = ->
    declareJasmineSpec(arguments)

  root.Then.only = ->
    declareJasmineSpec(arguments, it.only)

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

  jasmine._given =
    matchers:
      toHaveReturnedFalseFromThen: (context, n, done) ->
        result = false
        exception = undefined
        try
          result = @actual.call(context, done)
        catch e
          exception = e
        @message = ->
          stringyExpectation = stringifyExpectation(@actual)
          msg = "Then clause#{if n > 1 then " ##{n}" else ""} `#{stringyExpectation}` failed by "
          if exception
            msg += "throwing: " + exception.toString()
          else
            msg += "returning false"
          msg += additionalInsightsForErrorMessage(stringyExpectation)

          msg

        result == false

  stringifyExpectation = (expectation) ->
    matches = expectation.toString().replace(/\n/g,'').match(/function\s?\(.*\)\s?{\s*(return\s+)?(.*?)(;)?\s*}/i)
    if matches and matches.length >= 3 then matches[2].replace(/\s+/g, ' ') else ""

  additionalInsightsForErrorMessage = (expectationString) ->
    expectation = finalStatementFrom(expectationString)
    if comparison = wasComparison(expectation)
      comparisonInsight(expectation, comparison)
    else
      ""

  finalStatementFrom = (expectationString) ->
    if multiStatement = expectationString.match(/.*return (.*)/)
      multiStatement[multiStatement.length - 1]
    else
      expectationString

  wasComparison = (expectation) ->
    if comparison = expectation.match(/(.*) (===|!==|==|!=|>|>=|<|<=) (.*)/)
      [s, left, comparator, right] = comparison
      {left, comparator, right}

  comparisonInsight = (expectation, comparison) ->
    left = evalInContextOfSpec(comparison.left)
    right = evalInContextOfSpec(comparison.right)
    return "" if apparentReferenceError(left) && apparentReferenceError(right)

    msg = """
          \n
          This comparison was detected:
            #{expectation}
            #{left} #{comparison.comparator} #{right}
          """
    msg += "\n\n#{deepEqualsNotice(comparison.left, comparison.right)}" if attemptedEquality(left, right, comparison.comparator)
    msg

  apparentReferenceError = (result) ->
    /^<Error: "ReferenceError/.test(result)

  evalInContextOfSpec = (operand) ->
    try
      (-> eval(operand)).call(jasmine.getEnv().currentSpec)
    catch e
      "<Error: \"#{e?.message?() || e}\">"

  attemptedEquality = (left, right, comparator) ->
    (comparator == "==" || comparator == "===") && jasmine.getEnv().equals_(left, right)

  deepEqualsNotice = (left, right) ->
    """
    However, these items are deeply equal! Try an expectation like this instead:
      expect(#{left}).toEqual(#{right})
    """

  class Waterfall
    constructor: (functions = [], finalCallback) ->
      @functions = functions.slice(0)
      @finalCallback = finalCallback

      @asyncCount = 0
      for func in @functions
        @asyncCount += 1 if func.length > 0

    asyncTaskCompleted: =>
      @asyncCount -= 1
      @flow()

    invokeFinalCallbackIfNecessary: =>
      if @asyncCount == 0
        @finalCallback?()
        @finalCallback = undefined

    flow: =>
      return @invokeFinalCallbackIfNecessary() if @functions.length == 0

      func = @functions.shift()

      if func.length > 0
        func(@asyncTaskCompleted)
      else
        func()
        @flow()




) jasmine
