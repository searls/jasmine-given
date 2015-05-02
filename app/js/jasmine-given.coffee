((jasmine) ->

  mostRecentlyUsed = null

  root = `(1, eval)('this')`

  currentSpec = null
  beforeEach ->
    currentSpec = this

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
      context = currentSpec
      result = setupFunction.call(context, done)
      if assignResultTo
        unless context[assignResultTo]
          context[assignResultTo] = result
        else
          throw new Error("Unfortunately, the variable '#{assignResultTo}' is already assigned to: #{context[assignResultTo]}")

  mostRecentExpectations = null
  mostRecentStacks = null

  declareJasmineSpec = (specArgs, itFunction = it) ->
    label = o(specArgs).firstThat (arg) -> o(arg).isString()
    expectationFunction = o(specArgs).firstThat (arg) -> o(arg).isFunction()
    mostRecentlyUsed = root.subsequentThen
    mostRecentExpectations = expectations = [expectationFunction]
    mostRecentStacks = stacks = [errorWithRemovedLines("failed expectation", 3)]

    itFunction "then #{label ? stringifyExpectation(expectations)}", doneWrapperFor expectationFunction, (jasmineDone) ->
      userCommands = [].concat(whenList, invariantList, wrapAsExpectations(expectations, stacks))
      new Waterfall(userCommands, jasmineDone).flow()

    return { Then: subsequentThen,  And: subsequentThen }

  wrapAsExpectations = (expectations, stacks) ->
    for expectation, i in expectations
      do (expectation, i) ->
        doneWrapperFor expectation, (maybeDone) ->
          expect(expectation).not.toHaveReturnedFalseFromThen(currentSpec, i + 1, stacks[i], maybeDone)

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
    mostRecentStacks.push(errorWithRemovedLines("failed expectation", 3))
    this

  errorWithRemovedLines = (msg, n) ->
    if stack = new Error(msg).stack
      [error, lines...] = stack.split("\n")
      "#{error}\n#{lines.slice(n).join("\n")}"

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

  class Waterfall
    constructor: (functions = [], @finalCallback = ->) ->
      @functions = cloneArray(functions)

    flow: ->
      return @finalCallback() if @functions.length == 0
      func = @functions.shift()
      if func.length > 0
        func(=> @flow() )
      else
        func()
        @flow()

  cloneArray = (a) -> a.slice(0)

  jasmine._given =
    matchers:
      toHaveReturnedFalseFromThen: (context, n, stackTrace, done) ->
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
          msg += "\n\n" + stackTrace if stackTrace?
          msg

        result == false
    __Waterfall__: Waterfall

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
      (-> eval(operand)).call(currentSpec)
    catch e
      "<Error: \"#{e?.message?() || e}\">"

  attemptedEquality = (left, right, comparator) ->
    return false unless comparator is "==" || comparator is "==="
    if jasmine.matchersUtil?.equals?
      jasmine.matchersUtil.equals(left, right)
    else
      jasmine.getEnv().equals_(left, right)

  deepEqualsNotice = (left, right) ->
    """
    However, these items are deeply equal! Try an expectation like this instead:
      expect(#{left}).toEqual(#{right})
    """

  beforeEach ->
    if jasmine.addMatchers?
      jasmine.addMatchers(jasmine.matcherWrapper.wrap(jasmine._given.matchers))
    else
      @addMatchers(jasmine._given.matchers)

) jasmine
