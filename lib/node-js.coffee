url = require 'url'
NodeJsView = require './node-js-view'

module.exports =
  nodeJsView: null

  activate: (state) ->
    @nodeJsView = new NodeJsView(state.nodeJsViewState)
    atom.workspaceView.command "node-js:mocha-run", => @run()

    atom.workspace.registerOpener (uriToOpen) ->
      {protocol, pathname} = url.parse(uriToOpen)
      return unless protocol is 'node-js-output:'
      new NodeJsView(pathname)


  deactivate: ->
    @nodeJsView.destroy()

  serialize: ->
    nodeJsViewState: @nodeJsView.serialize()

  openUriFor: (file) ->
    previousActivePane = atom.workspace.getActivePane()
    uri = "node-js-output://#{file}"
    atom.workspace.open(uri, split: 'right', changeFocus: false, searchAllPanes: true).done (nodeJsView) ->
      if nodeJsView instanceof NodeJsView
        nodeJsView.run()
        previousActivePane.activate()

  run: ->
    console.log "RUN"
    editor = atom.workspace.getActiveEditor()
    return unless editor?

    @openUriFor(editor.getPath())
