Memory = require '../src/memory.coffee'

memory = null

flag =
  update: ->

describe "Memory", ->
  describe '#constructor', ->
    it "reset all values", ->
      memory = new Memory(null)
      expect(memory.memory[0]).toBe 0xffff
      expect(memory.pr).toBe 0
      expect(memory.sp).toBe 0xffff
      expect(memory.call_count).toBe 0

    it 'can change pr with initial value', ->
      memory = new Memory(null, 3)
      expect(memory.pr).toBe 3

  describe "#memset", ->
    beforeEach ->
      memory = new Memory(flag)
      spyOn flag, 'update'

    it 'set memory collect', ->
      memory.memset("\n\n\n0000:0000\n0001:0001\n")
      expect(memory.get(0)).toBe 0
      expect(memory.get(1)).toBe 1

  describe "#set,#get", ->
    beforeEach ->
      memory = new Memory(flag)
      spyOn flag, 'update'

    it "can read and write", ->
      memory.set(0xbead,0xbeef)
      expect(memory.get(0xbead)).toBe 0xbeef

    it "throw error on set invalid r ange", ->
      expect(-> memory.set(0x10000, 0)).toThrow()

  describe '#next', ->
    beforeEach ->
      memory = new Memory(flag)
      spyOn flag, 'update'

    it 'get instruction with size = 2', ->
      memory.set(0, 0x1000)
      memory.set(1, 0xdead)
      inst = memory.next()
      expect(inst.size).toBe 2
      expect(inst.address[0]).toBe 0xdead
      expect(memory.pr).toBe 2

    it "get instruction with size = 1", ->
      memory.set(0, 0x7110)
      inst = memory.next()
      expect(inst.size).toBe 1
      expect(inst.name).toBe 'pop'
      expect(inst.address.length).toBe 0
      expect(memory.pr).toBe 1

  describe "\#stack_exec", ->
    beforeEach ->
      memory = new Memory(flag)
      spyOn flag, 'update'

    it "exec push and pop", ->
      memory.stack_exec('push', 1, null)
      expect(memory.sp).toBe 0xfffe
      expect(memory.memory[0xfffe]).toBe 1
      r = memory.stack_exec('pop', null, null)
      expect(memory.sp).toBe 0xffff
      expect(r).toBe 1

    it "throws when push to full stack", ->
      memory.sp = 0
      expect(-> memory.stack_exec('push', 2, 3)).toThrow()

    it 'throws when pop from empty stack', ->
      expect(-> memory.stack_exec('pop', null, null)).toThrow()
