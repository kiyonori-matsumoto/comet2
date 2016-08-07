Alu = require('../src/alu.coffee')

alu = null

ADDA = { name: 'adda', type: 'ARITHMETIC', size: 2, target: 'gr'}
ADDL = { name: 'addl', type: 'LOGICAL', size: 2, target: 'gr'}
LAD  = { name: 'lad', size: 2, target: 'gr', effective: true }
SRL  = { name: 'srl', type: 'LOGICAL', size: 2, target: 'gr', effective: true }
SRA  = { name: 'sra', type: 'ARITHMETIC', size: 2, target: 'gr', effective: true }
SLL  = { name: 'sll', type: 'LOGICAL', size: 2, target: 'gr', effective: true }
XOR  = { name: 'xor', type: 'LOGICAL', size: 1, target: 'gr'}

flag =
  update: ->

describe 'Alu', ->
  beforeEach ->
    alu = new Alu(flag)

  describe '#exec', ->
    beforeEach ->
      spyOn flag, 'update'

    it 'should call flag#update on exec alu', ->
      result = alu.exec(ADDA, 2, 3)
      expect(result).toEqual(5)
      expect(flag.update).toHaveBeenCalled()

    it 'should not call flag#update on exec lad', ->
      result = alu.exec(LAD, 3, 4)
      expect(flag.update).not.toHaveBeenCalled()

    it 'becomes 1 when -2 + 3', ->
      result = alu.exec(ADDA, 0xfffe, 3)
      expect(result).toEqual(1)
      expect(flag.update).toHaveBeenCalledWith(1, false)

    it 'becomes 1 when 0xfffe + 3 (logically)', ->
      result = alu.exec(ADDL, 0xfffe, 3)
      expect(result).toEqual(1)
      expect(flag.update).toHaveBeenCalledWith(1, true)

    it 'becomes 0xa when 0xaa >> 4', ->
      result = alu.exec(SRL, 0xaa, 4)
      expect(result).toEqual(0xa)
      expect(flag.update).toHaveBeenCalledWith(0xa, true)

    it 'becomes 0x80 when 0x8000 >> 8', ->
      result = alu.exec(SRL, 0x8000, 8)
      expect(result).toEqual(0x80)
      expect(flag.update).toHaveBeenCalledWith(0x80, false)

    it 'becomes 0xffff when 0x8000 >> 15', ->
      result = alu.exec(SRA, 0x8000, 15)
      expect(result).toEqual(0xffff)
      expect(flag.update).toHaveBeenCalledWith(0xffff, false)

    it 'becomes 0xa5a0 when 0x5a5a << 4', ->
      result = alu.exec(SLL, 0x5a5a, 4)
      expect(result).toEqual(0xa5a0)
      expect(flag.update).toHaveBeenCalledWith(0xa5a0, true)

    it 'becomes 0xffff when 0xaaaa ^ 0x5555', ->
      result = alu.exec(XOR, 0xaaaa, 0x5555)
      expect(result).toEqual(0xffff)
