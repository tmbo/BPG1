### define
d3 : d3
lib/event_mixin : EventMixin
./graph : Graph
./behavior/connect_behavior : connectBehavior
./behavior/drag_behavior : dragBehavior
###

class InteractiveGraph extends Graph

  constructor : (@container, @svg) ->

    EventMixin.extend(this)
    @initArrowMarkers()

    @currentBehavior = new dragBehavior(@)
    @currentBehavior.activate()

    super(@container)


  initArrowMarkers : ->

    # define arrow markers for graph edges
    @svg.append("svg:defs")
      .append("svg:marker")
        .attr("id", "end-arrow")
        .attr("viewBox", "0 -5 10 10")
        .attr("refX", 6)
        .attr("markerWidth", 3)
        .attr("markerHeight", 3)
        .attr("orient", "auto")
      .append("svg:path")
        .attr("d", "M0,-5L10,0L0,5")
        .attr("fill", "#000")

    @svg.append("svg:defs")
      .append("svg:marker")
        .attr("id", "start-arrow")
        .attr("viewBox", "0 -5 10 10")
        .attr("refX", 4)
        .attr("markerWidth", 3)
        .attr("markerHeight", 3)
        .attr("orient", "auto")
      .append("svg:path")
        .attr("d", "M10,-5L0,0L10,5")
        .attr("fill", "#000")


  changeBehavior : (behavior) ->

    @currentBehavior.deactivate()
    @currentBehavior = behavior
    @currentBehavior.activate()











