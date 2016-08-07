GR = require '../src/gr.coffee'

gr = null
describe 'GR', ->
  describe '#get', ->
    beforeEach ->
      gr = new GR
    it 'returns 0 with arg null', ->
      expect(gr.get(null)).toEqual(0)

    it 'returns initial value', ->
      expect(gr.get(0)).toEqual(0xffff)

    it 'throws when range is wrong', ->
      expect(-> gr.get(8)).toThrow()

  describe '#constructor', ->
    it 'can change initial value', ->
      gr = new GR(0xd)
      expect(gr.get(0)).toEqual(0xd)

    it 'throws initial value is out-of-range', ->
      expect(-> new GR(-1)).toThrow()
      expect(-> new GR(0x10000)).toThrow()

  describe '#set', ->
    beforeEach ->
      gr = new GR(0xfffe)

    it 'can set and get', ->
      gr.set(0, 0)
      gr.set(1, 0xffff)
      expect(gr.gr[0]).toEqual(0)
      expect(gr.get(1)).toEqual(0xffff)
