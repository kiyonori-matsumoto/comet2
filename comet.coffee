Flag   = require('./flag.coffee')
Alu    = require('./alu.coffee')
Memory = require('./memory.coffee')
GR     = require('./gr.coffee')

class Comet2Simulator
  @initialize: (text) ->
    @flag = new Flag
    @alu  = new Alu(@flag)
    @memory = new Memory(@flag)
    @gr = new  GR
    @finished = false

    @memory.memset(text)

  @execute_step: ->
    return false if @finished

    i = @memory.next()
    console.log i

    a = @gr.get(i.gr[0])
    b =
      if (i.size == 1)
        @gr.get(i.gr[1])
      else if i.effective # effective address?
        i.address[0] + @gr.get(i.gr[1])
      else # content of effective address?
        @memory.get(i.address[0] + @gr.get(i.gr[1]))
    result = null

    if i.type == 'ALITHMETIC' || i.type == 'LOGICAL'
      result = @alu.exec(i, a, b)
    else if i.type == 'JUMP'
      @memory.pr = b if @flag.is_jumpable(i.name)
    else if i.type == 'STACK'
      result = @memory.stack_exec(i.name, a, b)
    else if i.type == 'CALL'
      if @memory.call_exec(i.name, b) < 0
        @finished = true
        return false
    else
      result = a

    if i.target == 'memory'
      @memory.set(i.address[0], result)
    else if i.target == 'gr'
      @gr.set(i.gr[0], result)

    console.log @gr
    console.log @flag

    true

  @execute: (text) ->
    this.initialize(text)
    while this.execute_step()
      ;

    console.log "Program exited successfully"

module.exports = Comet2Simulator
