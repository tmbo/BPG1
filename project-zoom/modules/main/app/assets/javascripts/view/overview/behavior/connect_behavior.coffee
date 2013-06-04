### define
core_ext : CoreExt
hammer : Hammer
./behavior : Behavior
###

class ConnectBehavior extends Behavior

  constructor : ( @graph, @container ) ->

    # line that is displayed when dragging a new edge between nodes
    if $(".drag-line").length == 0
      @dragLine = @container.insert("svg:path",":first-child") #prepend for proper zOrdering
      @dragLine
        .attr("class", "hide drag-line")
        .style('marker-end', 'url(#end-arrow)')
    else
      @dragLine = d3.select(".drag-line")


  activate : ->

    @hammerContext = Hammer( $(".graph svg")[0] )
      .on("drag", ".node-image", @dragMove)
      .on("dragend", ".node-image", @dragEnd)
      .on("dragstart", ".node-image", @dragStart)


  deactivate : ->

    @hammerContext
      .off("drag", @dragMove)
      .off("dragend", @dragEnd)
      .off("dragstart", @dragStart)

    @dragLine.classed("hide", true)


  dragStart : (event) =>

    @offset = $("#process-view").offset()
    @scaleValue = $(".zoom-slider input").val()

    @startPoint = @mousePosition(event)
    @startTranslation = d3.transform(graphContainer.attr("transform")).translate

  dragEnd : (event) =>

    startNode = d3.select($(event.gesture.startEvent.target).closest("foreignObject")[0]).datum()

    if targetElement = $(event.target).closest("foreignObject")[0]
      currentNode = d3.select(targetElement).datum()

      unless startNode == currentNode
        @graph.addEdge(startNode, currentNode)

    @dragLine.classed("hide", true)


  dragMove : (event) =>

    svgContainer = $(event.gesture.target).closest("foreignObject")[0]

    mouse = @mousePosition(event)

    nodeData = d3.select(svgContainer).datum()
    lineStart =
      x: nodeData.get("position/x")
      y: nodeData.get("position/y")

    lineEnd =
      x: mouse.x - @startPoint.x - @startTranslation[0]
      y: mouse.y - @startPoint.y - @startTranslation[1]

    @dragLine
      .classed("hide", false)
      .attr("d", "M #{lineStart.x},#{lineStart.y} L #{lineEnd.x},#{lineEnd.y}")
