Instruction = require '../src/instruction.coffee'

inst = null

describe 'Instruction', ->
  describe '.decode', ->
    it 'returns collect instruction', ->
      inst = Instruction.decode(0x1000)
      expect(inst.name).toBe('ld')
      expect(inst.size).toBe(2)

    it 'throws error with invalid code', ->
      expect(-> Instruction.decode(0xffff)).toThrow()

    it 'set gr from operand', ->
      inst = Instruction.decode(0x3254)
      expect(inst.name).toBe('xor')
      expect(inst.size).toBe 2
      expect(inst.gr[0]).toBe 5
      expect(inst.gr[1]).toBe 4

    it 'add address', ->
      inst = Instruction.decode(0x8001)
      inst.add_address(0xbead)
      expect(inst.address).toBe 0xbead
      expect(inst.name).toBe 'call'
