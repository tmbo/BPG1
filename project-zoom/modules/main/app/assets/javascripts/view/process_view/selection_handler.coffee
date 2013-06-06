### define
./behavior/behavior : Behavior
./behavior/connect_behavior : ConnectBehavior
./behavior/drag_behavior : DragBehavior
./behavior/delete_behavior : DeleteBehavior
./behavior/comment_behavior : CommentBehavior
app: App
###

class SelectionHandler

  constructor : (@$el, @graph) ->

    @behaviors =
      DRAG : new DragBehavior(@graph)
      CONNECT : new ConnectBehavior(@graph)
      DELETE : new DeleteBehavior(@graph)
      COMMENT : new CommentBehavior(@graph)
      IDLE : new Behavior(@graph)

    @selection = null

    @currentBehavior = @behaviors.IDLE

    app.on "behavior:done", =>
      if @selection
        @changeBehavior( @behaviors.DRAG )
      else
        @changeBehavior( @behaviors.IDLE )

    app.on "behavior:delete", => @unselect()
    app.on "behavior:drag", => @positionToolbar()
    app.on "behavior:zooming", => @positionToolbar()
    app.on "behavior:panning", => @positionToolbar()


  activate : ->

    @createToolBar()

    @hammerContext = Hammer( @graph.svgEl )
      .on("tap", ".node", @selectNode)
      .on("tap", ".cluster", @selectCluster)
      .on("dragstart", ".node", @selectNode)
      .on("dragstart", ".cluster", @selectCluster)

    @buttonContext = Hammer( @$tools[0] )
      .on("tap", "a", @selectBehavior)


  deactivate : ->

    @$tools.remove()

    @hammerContext
      .off("tap", @selectNode)
      .off("tap", @selectCluster)

    @buttonContext
      .off("tap", @changeBehavior)


  selectNode : (event) =>

    return unless event.gesture
    return if @currentBehavior instanceof ConnectBehavior #unclean workaround

    @selection = event.gesture.target

    @positionToolbar()
    @$tools
      .removeClass("node")
      .addClass("node") # make sure we only add the class once
      .show()

    @changeBehavior( @behaviors.DRAG )


  selectCluster : (event) =>


  createToolBar : ->

    unless @$tools
      template = """
      <div id="tool-bar">
        <a class="btn" href="#" id="connect"><i class="icon-arrow-right"></i></a>
        <a class="btn" href="#" id="delete"><i class="icon-trash"></i></a>
        <a class="btn" href="#" id="comment"><i class="icon-comment"></i></a>
      </div>
      """

      @$tools = $(template)
      @$tools.hide()

      @$el.append(@$tools)

  positionToolbar : ->

    if @selection

      boundingBox = @selection.getBoundingClientRect()

      @$tools.css(
        left: boundingBox.left
        top: boundingBox.top
        width: boundingBox.width
        height: boundingBox.height
      )

    else
      @$tools.hide()

  selectBehavior : (event) =>

    behavior = switch $(event.target).attr("id")
      when "delete" then @behaviors.DELETE
      when "comment" then @behaviors.COMMENT
      when "connect" then @behaviors.CONNECT
      else @behaviors.DRAG

    @changeBehavior( behavior )


  unselect : ->

    @selection = null
    @$tools.hide()
    @changeBehavior( @behaviors.IDLE )


  changeBehavior : (behavior) ->

    @currentBehavior.deactivate()
    @currentBehavior = behavior
    @currentBehavior.activate(@selection)