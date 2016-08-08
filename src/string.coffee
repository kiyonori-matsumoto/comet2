
String::is_gr = ->
  if this.match(/^GR[0-7]$/) then true else false

String::is_address = ->
  if this.is_gr() then false
  else if this.match(/^[A-Z][0-9A-Z]{0,7}$/)
    true
  else if this.match(/^\=/)
    true
  else
    false
