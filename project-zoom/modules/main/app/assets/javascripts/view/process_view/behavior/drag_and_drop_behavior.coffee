### define
./behavior : Behavior
app : app
###

class DragAndDropBehavior extends Behavior

  constructor : (@$el, @graph) ->


  activate : ->

    @hammerContext = Hammer(@$el.find("#artifact-finder")[0])
      .on("dragend", "image", @addArtifact)
      .on("dragstart", "image", @dragStart)
      .on("drag", "image", @dragMove)


  deactivate : ->

    @hammerContext
      .off("dragend", @addArtifact)
      .off("dragstart", @dragStart)
      .off("drag", @dragMove)


  addArtifact : (event) =>

    imageElement = $(event.gesture.target)
    touch = event.gesture.touches[0]

    #is the mouse over the SVG?
    @offset = @$el.find("#process-graph").offset()
    @scaleValue = app.view.zoom.level

    if touch.pageX > @offset.left and touch.pageY > @offset.top

      mouse = @mousePosition(event)
      artifactId = imageElement.data("id")

      translation = d3.transform(@graph.graphContainer.attr("transform")).translate

      position =
        x: mouse.x + translation[0]
        y: mouse.y + translation[1]

      @graph.addNode(mouse.x, mouse.y, artifactId)
      @$preview.remove()


  dragStart : (event) =>

    @offset = {left: 0, top: 0}
    @scaleValue = 1.0

    svgContainer = $(event.gesture.target).closest("svg").clone() #use clone for the preview, so that original stays within the artifacFinder
    mouse = @mousePosition(event)

    @$preview = $("<div>", {class: "drag-preview"})
      .css(
        position : "absolute"
        left: mouse.x #better use css transform, once it is prefix-free
        top: mouse.y
        width: "64px"
        height: "64px"
        "z-index": 100
      )

    @$preview.append(svgContainer)
    @$el.append(@$preview)


  dragMove : (event) =>

    mouse = @mousePosition(event)

    @$preview.css(
      left: mouse.x
      top: mouse.y
    )
