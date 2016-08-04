class Flag
  constructor: ->
    @of = @sf = @zf = false

  update: (value, overflag) ->
    @of = overflag
    @sf = (value & 0x8000) != 0
    @zf = (value & 0xFFFF) == 0

  is_jumpable: (name) ->
    switch name
      when 'jmi' then @sf
      when 'jnz' then !@zf
      when 'jze' then @zf
      when 'jump' then true
      when 'jpl' then !@sf
      when 'jov' then @of
      else
        throw 'Error'

  inspect: ->
    "sf:#{@sf}, zf:#{@zf}, of:#{@of}"

module.exports = Flag
