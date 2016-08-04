class GR
  constructor: (init = 0xffff) ->
    @gr = (init for _ in [0...8])

  get: (v) ->
    return 0 if !(v?)
    @gr[v]

  set: (a, v) ->
    throw 'GR set Range Error' if a < 0 || a > 7
    @gr[a] =  v

module.exports = GR
