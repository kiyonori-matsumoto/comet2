class Alu
  FUNCTIONS =
    ld: (a, b) -> [b, false]
    adda: (a, b) -> [a+b, overflow_a(a+b)]
    addl: (a, b) -> [a+b, overflow_l(a+b)]
    suba: (a, b) -> [a-b, overflow_a(a-b)]
    subl: (a, b) -> [a-b, overflow_l(a-b)]
    and:  (a, b) -> [a & b, false]
    or:   (a, b) -> [a | b, false]
    xor:  (a, b) -> [a ^ b, false]
    cpa:  (a, b) -> [a - b, false]
    cpl:  (a, b) -> [a - b, false]
    sla:  (a, b) -> [a << b, check_bit_l(a, b-1)]
    sra:  (a, b) -> [a >> b, check_bit_r(a, b-1)]
    sll:  (a, b) -> [a << b, check_bit_l(a, b-1)]
    srl:  (a, b) -> [a >> b, check_bit_r(a, b-1)]

  constructor: (flag) ->
    @flag = flag

  exec: (method,  a, b) ->
    return @result = a if !method.type || !(method.type == 'LOGICAL' || method.type == 'ARITHMETIC')
    [a, b] = to_arithmetic([a, b]) if method.type == 'ALITHMETIC'
    if FUNCTIONS[method.name]
      [@result, overflag] = FUNCTIONS[method.name](a, b)
    else
      throw "No Method"
    @flag.update(@result, overflag) if method.type
    @result &= 0xffff
    @result

  to_arithmetic = (v) ->
    ((if (item & 0x8000) == 0 then item else -(0x10000 - item)) for item in v)

  overflow_a = (v) ->
    v < 32768 || v > 32767

  overflow_l = (v) ->
    v < 0 || v > 0xffff

  check_bit_l = (a, b) ->
    if b == 0 then false else (a << (b - 1)) & 0x8000

  check_bit_r = (a, b) ->
    if b == 0 then false else (a >> (b - 1)) & 0x1

module.exports = Alu
