Waterfall = jasmine._given.__Waterfall__
packFunctions = (n, fn)->
  (fn for i in [0...n])

#Repitition of the closures and lack of nesting is very intentional
#as to keep the async calls reasonable.

describe "Waterfall", ->

  context "basic run", ->
    counter = null
    Given -> counter = 0
    When -> new Waterfall(packFunctions(100, -> counter++), ->).flow()
    Then -> expect(counter).toBe(100)

  xcontext "when we have 128,000 functions", ->
    counter = null
    Given -> counter = 0
    When -> new Waterfall(packFunctions(128000, -> counter++), ->).flow()
    Then -> expect(counter).toBe(128000)

  context "final fn runs last", ->
    counter = null
    countDuringFinal = null
    Given -> counter = 0
    Given -> @finalFn = -> countDuringFinal = 100
    When -> new Waterfall(packFunctions(100, -> counter++), @finalFn).flow()
    Then -> expect(countDuringFinal).toBe(counter)

  context "with async functions", ->
    counter = null
    asyncCounter = null
    counterDuringFinal = null
    Given -> [counter, asyncCounter] = [0, 0]
    Given ->
      @asyncFn = (done)->
        setTimeout ->
          counter++
          asyncCounter++
          done()
        , 9

    Given -> @finalFn = -> counterDuringFinal = counter
    Given ->
      @functions = packFunctions(100, -> counter++).
        concat(packFunctions(5, @asyncFn)).
        concat(packFunctions(100, -> counter++)).
        concat(packFunctions(5, @asyncFn))

    When -> new Waterfall(@functions, @finalFn).flow()
    Then ->
      waitsFor ->
        asyncCounter == 10
      , "10 async functions", 100
      runs ->
        expect(counter).toBe(210)
    And ->
      runs ->
        expect(counterDuringFinal).toBe(counter)

