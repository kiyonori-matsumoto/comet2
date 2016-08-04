Instruction = require('./instruction.coffee')

class Memory
  constructor: (@flag, pr_init = 0) ->
    @memory = (0xffff for _ in [0..0xffff])
    @pr = pr_init
    @sp = 0xffff
    @call_count = 0

  memset: (str) ->
    @mem_max = 0
    for s in str.split(/\r\n|\r|\n/)[3..-1]
      continue unless s.match(/:/)
      [a, v] = s.split(/:/)
      a = parseInt(a,  16)
      v = parseInt(v, 16)
      this.set(a, v)
      @mem_max = Math.max(a, @mem_max)

  get: (v) ->
    return 0 if v < 0 || v > 65535
    @memory[v]

  set: (a, v) ->
    throw "Range Error" if a < 0 || a > 0xffff
    @memory[a] = v

  next: ->
    inst = Instruction.decode(@memory[@pr])
    @pr += 1
    if inst.size > 1
      inst.add_address(@memory[@pr])
      @pr += 1
    inst

  stack_exec: (name, a, b) ->
    if name == 'push'
      @sp -= 1
      @memory[@sp] = a
    else if name == 'pop'
      throw "Cannot pop nomore" if @sp > 0xffff
      @sp += 1
      @memory[@sp - 1]
    else
      throw 'Not stack operation?'

  call_exec: (name, b) ->
    if name == 'call'
      this.stack_exec('push', @pr, 0)
      @pr = b
      @call_count += 1
    else if name == 'ret'
      @pr = this.stack_exec('pop', 0, 0)
      @call_count -= 1

  inspect: ->
    "[#{@memory[0..@mem_max].map (e) -> e.toString(16)}]"

module.exports = Memory
