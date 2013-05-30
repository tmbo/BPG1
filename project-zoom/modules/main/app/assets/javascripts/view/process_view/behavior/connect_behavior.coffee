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

    @hammerContext = Hammer( $("#process-graph")[0] )
      .on("drag", ".node", @dragMove)
      .on("dragend", ".node", @dragEnd)
      .on("dragstart", ".node", @dragStart)


  deactivate : ->

    @hammerContext
      .off("drag", @dragMove)
      .off("dragend", @dragEnd)
      .off("dragstart", @dragStart)

    @dragLine.classed("hide", true)


  dragStart : (event) =>

    @offset = $("#process-graph").offset()
    @scaleValue = $(".zoom-slider input").val()


  dragEnd : (event) =>

    startNode = d3.select(event.gesture.startEvent.target).datum()

    if targetElement = d3.select(event.target)
      currentNode = targetElement.datum()

      unless startNode == currentNode or typeof currentNode == "undefined"
        @graph.addEdge(startNode, currentNode)

    @dragLine.classed("hide", true)


  dragMove : (event) =>

    mouse = @mousePosition(event)

    nodeData = d3.select(event.gesture.target).datum()
    lineStartX = nodeData.get("position/x")
    lineStartY = nodeData.get("position/y")

    @dragLine
      .classed("hide", false)
      .attr("d", "M #{lineStartX},#{lineStartY} L #{mouse.x},#{mouse.y}")
