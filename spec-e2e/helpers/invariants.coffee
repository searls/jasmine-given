root = global

root.invariants =
  passingSpec: ->
    Invariant -> @result.code == 0
    Invariant -> expect(@result.output).toContain """
      # fail  0

      # ok
    """
