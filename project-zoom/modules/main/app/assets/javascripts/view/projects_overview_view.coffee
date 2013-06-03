### define
lib/event_mixin : EventMixin
d3 : d3
app : app
./overview/projectGraph : ProjectGraph
./overview/gui : GUI
./overview/behavior/behavior : Behavior
./overview/behavior/connect_behavior : ConnectBehavior
./overview/behavior/drag_behavior : DragBehavior
./overview/behavior/delete_behavior : DeleteBehavior
../component/tagbar : Tagbar
jquery : $
###

class ProjectsOverviewView

  constructor : ->

    @initTagbar()
    @gui = new GUI(@tagbar)
    @initGraph()

    $(".tagbarItem input").on "click", (event) => @graph.updateVennDiagram(event.currentTarget)

    EventMixin.extend(this)

    @activate()

  initTagbar : ->

    @tagbar = new Tagbar()
    $("#tagbar").append( @tagbar.domElement )


  deactivate : ->

    $("body").off("dragstart")

    $(".btn-group a").off("click")
    $(".zoom-slider")
      .off("change")
      .off("click")

    @graph.changeBehavior(new Behavior())
    @gui.deactivate()
    @tagbar.deactivate()


  activate : ->

    @gui.activate()
    @tagbar.activate()

    # drag artifact into graph
    $("body").on( "dragstart", "#artifact-finder .artifact-image", (e) -> e.preventDefault() )

    # change tool from toolbox
    processView = this
    $(".btn-group a").on "click", (event) -> processView.changeBehavior(this)

    # zooming
    $(".zoom-slider")
      .on("change", "input", @zoom)
      .on("click", ".plus", => @changeZoomSlider(0.1) )
      .on("click", ".minus", => @changeZoomSlider(-0.1) )

    do =>

      mouseDown = false

      $(".graph").on "mousewheel", (evt, delta, deltaX, deltaY) =>

        evt.preventDefault()
        return if mouseDown
        if deltaY > 0
          @changeZoomSlider(0.1)
        else
          @changeZoomSlider(-0.1)


  changeBehavior : (selectedTool) =>

    graph = @graph
    graphContainer = @graph.graphContainer

    toolBox = $(".btn-group a")
    behavior = switch selectedTool

      when toolBox[0] then new DragBehavior(graph)
      when toolBox[1] then new ConnectBehavior(graph, graphContainer)
      when toolBox[2] then new DeleteBehavior(graph)

    graph.changeBehavior( behavior )


  zoom : (event) =>

    scaleValue = $(".zoom-slider input").val()

    @graph.graphContainer.attr("transform", "scale( #{scaleValue} )") #"translate(" + d3.event.translate + ")
    @trigger("view:zooming")


  changeZoomSlider : (delta) ->

    $slider = $(".zoom-slider input")
    sliderValue = parseFloat($slider.val())
    $slider.val( sliderValue + delta )

    @zoom()


  initGraph : ->

    @domElement = d3.select(".graph svg")
    @graphContainer = @domElement.append("svg:g")

    @projects = []

    app.model.projects.forEach( (project) =>

      p =
        id:           project.get("id")
        name:         project.get("name")
        season:       project.get("season")
        year:         project.get("year")
        length:       project.get("length")
        participants: project.get("participants")
        image:        "http://upload.wikimedia.org/wikipedia/commons/9/96/Naso_elegans_Oceanopolis.jpg"
        width:        "100px"
        height:       "100px"
        tags:         [project.get("season")]    # to be set to "year"!

      @projects.push p
    )

    @graph = new ProjectGraph(@graphContainer, @domElement, @projects)
    @graph.drawProjects()








