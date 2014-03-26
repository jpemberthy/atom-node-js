{$, ScrollView} = require 'atom'
{spawn} = require 'child_process'
path = require 'path'

module.exports =
class NodeJsView extends ScrollView
  atom.deserializers.add(this)

  @content: ->
    @div class: 'node-js', =>
      @pre class: 'node-js-output'

  initialize: (file) ->
    super
    console.log "File:", file
    @file = file

    @output = @find(".node-js-output")
    @output.on("click", @terminalClicked)


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  getTitle: ->
    "node.js - #{path.basename(@file)}"

  getUri: ->
    "node-js-output://#{@file}"

  terminalClicked: (e) =>
    if e.target?.href
      line = $(e.target).data('line')
      file = $(e.target).data('file')
      console.log(file)
      file = "#{atom.project.getPath()}/#{file}"

      promise = atom.workspace.open(file, { searchAllPanes: true, initialLine: line })
      promise.done (editor) ->
        editor.setCursorBufferPosition([line-1, 0])

  run: (line_number) ->
    @output.empty()
    project_path = atom.project.getRootDirectory().getPath()

    # specCommand = atom.config.get("node.js.command")
    testCmd = "node_modules/mocha/bin/mocha"
    cmd = "#{testCmd} -C #{@file}"

    console.log "[node.js] running: #{cmd}"

    terminal = spawn("bash", ["-l"])

    terminal.on 'close', @onClose

    terminal.stdout.on 'data', @onStdOut
    terminal.stderr.on 'data', @onStdErr

    terminal.stdin.write("cd #{project_path} && #{cmd}\n")
    terminal.stdin.write("exit\n")

  addOutput: (output) =>

    output = "#{output}"
    output = output.replace /([^\s]*:[0-9]+)/g, (match) ->
      file = match.split(":")[0]
      line = match.split(":")[1]
      "<a href='#{file}' data-line='#{line}' data-file='#{file}'>#{match}</a>"

    @output.append("#{output}")
    @scrollTop(@[0].scrollHeight)

  onStdOut: (data) =>
    @addOutput data

  onStdErr: (data) =>
    @addOutput data

  onClose: (code) =>
    console.log "[node.js] exit with code: #{code}"
