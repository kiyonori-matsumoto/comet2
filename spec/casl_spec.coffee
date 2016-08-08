Casl = require '../src/casl.coffee'

LD = 'LABEL LD GR1,GR2 comment test'

describe "Casl", ->
  describe ".parse", ->
    it 'can parse with label', ->
      r = Casl.parse LD
      expect(r).toEqual(jasmine.any(Array))
      expect(r.length).toBe 1
      expect(r[0]).toEqual([['LABEL'], ['LD'], ['GR1','GR2'], 'comment test'])

    it 'can parse without label', ->
      r = Casl.parse "\t ST\tGR7,ADDR ; comment"
      expect(r).toEqual(jasmine.any(Array))
      expect(r.length).toBe 1
      expect(r[0]).toEqual([[''], ['ST'], ['GR7','ADDR'], '; comment'])

    it 'can parse with comment', ->
      r = Casl.parse "\tNOP ; comment"
      expect(r).toEqual(jasmine.any(Array))
      expect(r.length).toBe 1
      expect(r[0]).toEqual([[''], ['NOP'], [], '; comment'])

  describe ".to_inst", ->
    it "can decode instruction LD", ->
      r = Casl.parse LD
      r = Casl.to_inst(r)
      expect(r.length).toBe 1
      expect(r[0].name).toBe 'ld'
      expect(r[0].size).toBe 1
      expect(r[0].gr).toEqual [1, 2]
      expect(r[0].address).toBeNull

    it 'can decode instruction with address', ->
      r = Casl.to_inst(Casl.parse('  ST  GR7,LABEL '))
      expect(r.length).toBe 1
      expect(r[0].name).toBe 'st'
      expect(r[0].size).toBe 2
      expect(r[0].gr).toEqual [7, null]
      expect(r[0].address).toBe 'LABEL'
      expect(r[0].current_address).toBe 0

    it 'can decode instruction dc', ->
      r = Casl.to_inst(Casl.parse("DATA DC 10,#20,'test',NIKAIDO"))
      expect(r.length).toBe 1
      expect(r[0].name).toBe 'dc'
      expect(r[0].size).toBe 7
      expect(r[0].data).toEqual [10, 0x20, 116, 101, 115, 116, "NIKAIDO"]
