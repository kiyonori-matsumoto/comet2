Comet2Simulator = require('./comet.coffee')
Casl = require('./casl.coffee')
sprintf = require('sprintf').sprintf

$ ->
  $('#compile').on('click', ->
    casl = new Casl
    compiled_data = casl.compile($('#casl').val())
    # $('#compiled_data').val(compile_data)
    i = 0
    str = "<thead><tr class='thead-inverse'><th>ADDR</th><th colspan='4'>DATA</th></tr></thead>"
    for c in compiled_data
      if i % 4 == 0
        str += "<tr><th>#{sprintf("%04X", i)}</th>"
      str += "<td>#{sprintf("%04X", c)}</td>"
      if i % 4 == 3
        str += "</tr>\n"
      i += 1
    $('#memory').html(str)
    )

  document.getElementById('casl').addEventListener 'keydown', (e) ->
    if e.keyCode is 9
      e.preventDefault() if e.preventDefault
      elem = e.target
      start = elem.selectionStart
      end = elem.selectionEnd
      value = elem.value
      elem.value = "#{value.substring 0, start}\t#{value.substring end}"
      elem.selectionStart = elem.selectionEnd = start + 1
      false

  # $('#data').draggable()

  $('td').dblclick ->
    $(this).css('color','red')

  ((mod) ->
    if typeof exports == "object" && typeof module == "object"
      mod(require("codemirror"))
    else if typeof define == "function" && define.amd
      define(["codemirror"], mod)
    else
      mod(CodeMirror)
  )( (CodeMirror) ->
    "use strict"
    CodeMirror.defineMode("casl", (config) ->
      isInstruction = (str) ->
        for i in ["LD", "ST", "LAD", "ADDA", "ADDL", "SUBA", "SUBL"]
          if i == str
            return true
        false

      tokenBase = (stream, state) ->
        if stream.sol()
          state.tok = 0

        if state.tok >= 3
          stream.skipToEnd()
          "comment"
        else
          if stream.eatSpace()
            state.tok += 1
            null
          else if stream.peek() == "'"
            tokenString(stream)
            "string"
          else if stream.peek() == ';'
              stream.skipToEnd()
              "comment"
          else if m = stream.match(/[^,\s]+/)
            switch state.tok
              when 0
                if m[0].length <= 8 then "variable-3" else null
              when 1
                if isInstruction(m[0]) then "keyword" else null
              when 2
                if m[0].match(/^GR[0-7]$/) then "variable-2"
                else if m[0].match(/^=?-?\d+$/) then "number"
                else if m[0].match(/^=?#[0-9A-Fa-f]+$/) then "number"
                else if m[0].length <= 8 then "variable-3"
                else
                  null
              else "comment"
          else
            stream.eat(/./)
            null

      tokenString = (stream) ->
        stream.next()
        while (s = stream.next())
          if s == "'"
            if stream.peek() == "'"
              stream.next()
            else
              break


      {
        startState: ->
          {
            tokenize: tokenBase
            lineComment: ";"
            tok: 0
          }

        token: (stream, state) ->
          state.tokenize(stream, state)
      }
    myCodeMirror = CodeMirror.fromTextArea(document.getElementById("casl"), {mode: 'casl', lineNumbers: true})
    myCodeMirror.setOption("extraKeys", {
      'Ctrl-/': (cm) ->
        cm.toggleComment({from: cm.getCursor()})
      })
    )
  )
