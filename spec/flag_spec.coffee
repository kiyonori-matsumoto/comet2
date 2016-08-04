Flag = require('../src/flag.coffee')

check_flag = (flag, h = {}) ->
  expect(flag.of).toBe(h['of']?)
  expect(flag.sf).toBe(h['sf']?)
  expect(flag.zf).toBe(h['zf']?)

describe 'Flag', ->
  describe '#constructor', ->
    it 'clear all flag on construct', ->
      flag = new Flag
      check_flag(flag)

  describe '#update', ->
    flag = null
    beforeEach ->
      flag = new Flag

    it 'updates no flag on plus, non-zero', ->
      flag.update(1, false)
      check_flag(flag)

    it 'updates zero flag on value zero', ->
      flag.update(0, false)
      check_flag(flag, {zf: true})

    it 'updates signed flag on minus value', ->
      flag.update(-1, false)
      check_flag(flag, {sf: true})

    it 'updates overflow flag', ->
      flag.update(1, true)
      check_flag(flag, {of: true})

    it 'updates sf on  value bit15 = 1', ->
      flag.update(0x8000, false)
      check_flag(flag, {sf: true})

    it 'updates zf on overflowed value', ->
      flag.update(0x10000, false)
      check_flag(flag, {zf: true})

  describe '#is_jumpable', ->
    flag = null
    beforeEach ->
      flag = new Flag

    it 'is true when sf is true on jmi', ->
      flag.update(-1, false)
      expect(flag.is_jumpable('jmi')).toBe(true)

    it 'is true when zf is false on jnz', ->
      flag.update(1, false)
      expect(flag.is_jumpable('jnz')).toBe(true)
      expect(flag.is_jumpable('jov')).toBe(false)
      expect(flag.is_jumpable('jmi')).toBe(false)

    it 'is true when zf is true on jze', ->
      flag.update(0, false)
      expect(flag.is_jumpable('jze')).toBe(true)
      expect(flag.is_jumpable('jnz')).toBe(false)

    it 'is always true on jump', ->
      flag.update(0, true)
      expect(flag.is_jumpable('jump')).toBe(true)

    it 'is true when sf is false on jpl', ->
      flag.update(1, true)
      expect(flag.is_jumpable('jpl')).toBe(true)
      expect(flag.is_jumpable('jze')).toBe(false)

    it 'is true when of is true on jov', ->
      flag.update(-1, true)
      expect(flag.is_jumpable('jov')).toBe(true)
      expect(flag.is_jumpable('jpl')).toBe(false)
