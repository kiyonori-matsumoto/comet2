class Instruction
  RANGE_GR = [0...8]
  @INSTRUCTIONS:
    0x00: { name: 'nop', size: 1}
    0x10: { name: 'ld', type: 'LOGICAL', size: 2, target: 'gr'}
    0x11: { name: 'st', size: 2, target: 'memory' }
    0x12: { name: 'lad', size: 2, target: 'gr', effective: true }
    0x14: { name: 'ld', type: 'LOGICAL', size: 1, target: 'gr' }
    0x20: { name: 'adda', type: 'ARITHMETIC', size: 2, target: 'gr'}
    0x21: { name: 'suba', type: 'ARITHMETIC', size: 2, target: 'gr'}
    0x22: { name: 'addl', type: 'LOGICAL', size: 2, target: 'gr'}
    0x23: { name: 'subl', type: 'LOGICAL', size: 2, target: 'gr'}
    0x24: { name: 'adda', type: 'ARITHMETIC', size: 1, target: 'gr'}
    0x25: { name: 'suba', type: 'ARITHMETIC', size: 1, target: 'gr'}
    0x26: { name: 'addl', type: 'LOGICAL', size: 1, target: 'gr'}
    0x27: { name: 'subl', type: 'LOGICAL', size: 1, target: 'gr'}
    0x30: { name: 'and', type: 'LOGICAL', size: 2, target: 'gr'}
    0x31: { name: 'or', type: 'LOGICAL', size: 2, target: 'gr'}
    0x32: { name: 'xor', type: 'LOGICAL', size: 2, target: 'gr'}
    0x34: { name: 'and', type: 'LOGICAL', size: 1, target: 'gr'}
    0x35: { name: 'or', type: 'LOGICAL', size: 1, target: 'gr'}
    0x36: { name: 'xor', type: 'LOGICAL', size: 1, target: 'gr'}
    0x40: { name: 'cpa', type: 'ARITHMETIC', size: 2}
    0x41: { name: 'cpl', type: 'LOGICAL', size: 2}
    0x44: { name: 'cpa', type: 'ARITHMETIC', size: 1}
    0x45: { name: 'cpl', type: 'LOGICAL', size: 1}
    0x50: { name: 'sla', type: 'ARITHMETIC', size: 2, target: 'gr', effective: true }
    0x51: { name: 'sra', type: 'ARITHMETIC', size: 2, target: 'gr', effective: true }
    0x52: { name: 'sll', type: 'LOGICAL', size: 2, target: 'gr', effective: true }
    0x53: { name: 'srl', type: 'LOGICAL', size: 2, target: 'gr', effective: true }
    0x61: { name: 'jmi', type: 'JUMP', size: 2, effective: true }
    0x62: { name: 'jnz', type: 'JUMP', size: 2, effective: true }
    0x63: { name: 'jze', type: 'JUMP', size: 2, effective: true }
    0x64: { name: 'jump', type: 'JUMP', size: 2, effective: true }
    0x65: { name: 'jpl', type: 'JUMP', size: 2, effective: true }
    0x66: { name: 'jov', type: 'JUMP', size: 2, effective: true }
    0x70: { name: 'push', type: 'STACK', size: 2, effective: true }
    0x71: { name: 'pop', type: 'STACK', size: 1, target: 'gr'}
    0x80: { name: 'call', type: 'CALL', size: 2, effective: true }
    0x81: { name: 'ret', type: 'CALL', size: 1 }

  constructor:  ({@name, @type, @size, @target, @effective, @gr, @data, @address = null}) ->

  add_address: (a) ->
    @address = a

  calc_size: ->
    if @address?
      @size = 2
    else if @data?
      @size = @data.length
    else
      @size = 1
    this

  @decode: (code) ->
    h = this.INSTRUCTIONS[code >> 8]
    throw 'No Instruction' unless h?
    h['gr'] = [(code >> 4) & 0xf , code & 0xf]
    h['gr'][1] = null if h['gr'][1] == 0 && h['size'] >= 2
    new Instruction(h)

  to_code: ->
    for k, inst in Instruction.INSTRUCTIONS
      if @name == inst.name && @size == inst.size
        buf = k << 8
        buf |= @gr[0] << 4
        buf |= if @gr[1]? then @gr[1] else 0
        ret = [buf]
        if @size == 2
          ret.push @address
        return ret

    if @name == 'dc'
      return @data.map (e) ->
        e & 0xffff
    else if @name == 'ds'
      return (0xffff for _ in [0...@size])
    null

module.exports = Instruction
