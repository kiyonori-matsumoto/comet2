Labels = require('../src/label.coffee')

label = null

describe "Labels", ->
  describe '#add', ->
    beforeEach ->
      label = new Labels

    it "add and find", ->
      label.add('a', 2)
      label.add('b', 3)
      expect(label.find('a')).toBe 2
      expect(label.find('b')).toBe 3
      expect(label.find('c')).toBeNull()

    it 'throws with same label', ->
      label.add('a', 4)
      expect(-> label.add('a', 3)).toThrow()
