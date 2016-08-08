# Here your code !
StringScanner = require 'StringScanner'
Instruction   = require './instruction.coffee'
Labels         = require('./label.coffee')
require './string.coffee'

class Casl
  @compile: (src) ->
    insts = @parse(src)
    insts = @to_inst(insts)
    @to_code(insts)

  @parse: (src) ->
    ss = new StringScanner(src)
    buf = ""
    bufs = []
    inst = []
    insts = []

    finish = (comment = null) ->
      space()
      if comment?
        inst[3] = [comment]
      insts.push(inst) unless inst.length == 0
      inst = []

    comma = ->
      bufs.push(buf) if buf.length != 0 || inst.length == 0
      buf = ""

    space = ->
      comma()
      inst.push(bufs) unless bufs.length == 0
      bufs = []

    until ss.eos()
      if inst.length == 3
        inst[3] = ss.scan(/.+$/)
      else if m = ss.scan(/;.+$/)
        inst[2] ||= []
        inst[3] = m
      else if m = ss.scan(/'.*?'(?!')/)
        throw "Error0" unless buf.length == 0
        buf = m
      else if m = ss.scan(/[^,\s]+/)
        throw "Error1" unless buf.length == 0
        buf = m
      else if ss.scan /\r\n|\r|\n/
        finish()
      else if ss.scan /\s+/
        space()
      else if ss.scan /,/
        comma()
      else
        throw 'Parser Error'

    finish()
    insts

  @to_inst: (insts) ->
    labels = new Labels
    current_address = 0
    b = for inst in insts
      i = null
      if inst[1]? && inst[1][0]?
        i = switch inst[1][0]
          when 'DC'
            data = get_data(inst[2])
            new Instruction({name: 'dc', size: data.length, data: data})
          when 'DS'
            new Instruction({name: 'ds', size: parseInt(inst[2], 10)})
          when 'START'
            new Instruction({name: 'start', size: 0})
          when 'END'
            new Instruction({name: 'end', size: 0})
          else
            d = parse_operand(inst[2])
            new Instruction({name: inst[1][0].toLowerCase(), gr: d.gr, address: d.address}).calc_size()
      if inst[0]? && inst[0][0]?
        throw 'syntax error' if inst[0].length != 1
        labels.add(inst[0][0], current_address) if inst[0][0].length != 0
        i.current_address = current_address

      current_address += i.size
      i

  @to_code = (insts) ->
    for i in insts
      0

  get_data = (data) ->
    ret = []
    for d in data
      if d.match(/^'.*'(?!')$/)
        d.replace(/''/, "'")
        for c in d[1..-2]
          ret.push c.charCodeAt(0)
      else if d.match /^-?\d+$/
        ret.push(parseInt(d, 10) & 0xffff)
      else if d.match /^#[0-9a-fA-F]+$/
        v = parseInt(d[1..-1], 16)
        if v < 0 || v > 0xffff
          throw "hex range over"
        ret.push v
      else if d.is_address()
        ret.push d
      else
        console.log "Error, #{d}"
    ret

  parse_operand = (data) ->
    is_gr = (s) ->
      if s.match(/^GR[0-7]$/) then true else false

    is_address = (s) ->
      if is_gr(s) then false
      else if s.match(/^[A-Z][0-9A-Z]{0,7}$/)
        true
      else if s.match(/^\=/)
        true
      else
        false

    a = null
    gr= [null, null]
    grp = 0
    for d in data
      if is_gr(d)
        gr[grp] = parseInt(d[2], 10)
        grp+=1
      else if is_address(d)
        throw 'multiple address' if a?
        a = d
      else
        throw "operand #{d} is not address or gr"
    throw "many gr found" if gr.length > 2
    {address: a, gr: gr}

module.exports = Casl
