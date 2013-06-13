### define
./behavior : Behavior
hammer : Hammer
app : app
###

class PanBehavior extends Behavior

  constructor : (@$el, @graph) ->

    @active = false

    app.on "behavior:enable_panning", => @activate()
    app.on "behavior:disable_panning", => @deactivate()

    super(@graph)


  activate : ->

    unless @active
      @hammerContext = Hammer(@graph.svgEl)
        .on("dragstart", @panStart)
        .on("drag", @pan)

      @active = true


  deactivate : ->

    if @active
      @hammerContext
        .off("dragstart", @panStart)
        .off("drag", @pan)

      @active = false


  panStart : (event) =>

    return unless event.gesture

    @scaleValue = app.view.process.zoom
    @startPoint = @mousePosition(event)

    graphContainer = @graph.graphContainer


  pan : (event) =>

    return unless event.gesture
    target = d3.select(event.gesture.target)

    if target.classed("node")
      return

    mouse = @mousePosition(event)
    graphContainer = @graph.graphContainer
    transformation = d3.transform(graphContainer.attr("transform"))

    deltaX = ( mouse.x - @startPoint.x ) * @scaleValue
    deltaY = ( mouse.y - @startPoint.y ) * @scaleValue

    x = transformation.translate[0] + deltaX
    y = transformation.translate[1] + deltaY


    transformation.translate = [x, y]

    graphContainer.attr("transform", transformation.toString())

    @startPoint = mouse
    app.trigger "behavior:panning"