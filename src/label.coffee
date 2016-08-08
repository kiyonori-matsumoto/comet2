class Labels
  constructor: ->
    @ary = []
    this

  add: (name, addr) ->
    if this.find(name)?
      throw 'multiple same label'
    @ary.push([name, addr])

  find: (name) ->
    for a in @ary
      if a[0] == name
        return a[1]
    null

module.exports = Labels;
