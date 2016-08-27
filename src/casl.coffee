# Here your code !
StringScanner = require 'StringScanner'
Instruction   = require './instruction.coffee'
Labels         = require('./label.coffee')
require './string.coffee'

class Casl
  constructor: ->
    @labels = new Labels
    this

  compile: (src) ->
    insts = this.parse(src)
    insts = this.to_inst(insts)
    insts = this.to_code(insts)

  parse: (src) ->
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

  to_inst: (insts) ->
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
      else
        continue
      if inst[0]? && inst[0][0]?
        throw 'syntax error' if inst[0].length != 1
        @labels.add(inst[0][0], current_address) if inst[0][0].length != 0
        i.current_address = current_address

      current_address += i.size
      i

  to_code: (insts) ->
    r = []
    for i in insts
      r.push i.to_code()...
    r.map (e) =>
      if typeof(e) == 'string' then @labels.find(e) else e


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
    return {address: null, gr: [0, null]} unless data?
    a = null
    gr= [null, null]
    grp = 0
    for d in data
      if d.is_gr()
        gr[grp] = parseInt(d[2], 10)
        grp+=1
      else if d.is_address()
        throw 'multiple address' if a?
        a = d
      else
        throw "operand #{d} is not address or gr"
    throw "many gr found" if gr.length > 2
    {address: a, gr: gr}

module.exports = Casl
