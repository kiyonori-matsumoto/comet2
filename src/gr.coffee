class GR
  constructor: (init = 0xffff) ->
    if (init < 0 | init > 0xffff)
      throw 'GR initial value must between 0 ~ 0xffff'
    @gr = (init for _ in [0...8])

  get: (v) ->
    return 0 if !(v?)
    throw 'GR range error' if v < 0 || v > 7
    @gr[v]

  set: (a, v) ->
    throw 'GR set Range Error' if a < 0 || a > 7
    if (v < 0 | v > 0xffff)
      throw 'GR value must between 0 ~ 0xffff'
    @gr[a] =  v

module.exports = GR
