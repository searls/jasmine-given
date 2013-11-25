root = global

root.invariants =
  passingSpec: ->
    Invariant -> @result.code == 0
    Invariant -> @result.stderr == ""
    Invariant -> expect(@result.stdout).toContain """
      # fail  0

      # ok
    """
