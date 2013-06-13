### define
lib/event_mixin : EventMixin
underscore : _
jquery : $
d3 : d3
app : app
./overview/projectGraph : ProjectGraph
./overview/gui : GUI
../component/tagbar : Tagbar
./wheel : Wheel
text!templates/overview_view.html : OverviewTemplate
###

class ProjectsOverviewView

  IMAGE_FOLDER = "/assets/images/letter_images/"

  constructor : (@projectsCollection) ->

    EventMixin.extend(this)
    @$el = $(OverviewTemplate)
    @el = @$el[0]

    @initTagbar()
    @gui = new GUI(@tagbar, @$el)
    @initGraph()

    @wheel = new Wheel(@$el)


  initTagbar : ->

    @tagbar = new Tagbar()
    @$el.find("#tagbar").append( @tagbar.domElement )


  activate : ->

    @gui.activate()
    @tagbar.activate()
    @wheel.activate()
    @wheel.on("delta", app.view.overview.changeZoom)

    @$el.find(".tagbarItem input").on "click", (event) => @graph.updateVennDiagram(event.currentTarget)

    # drag artifact into graph
    @$el.on( "dragstart", "#artifact-finder .artifact-image", (e) -> e.preventDefault() )

    app.view.overview.on(this, "zoom", @zoom)
    @graph.drawProjects()


  deactivate : ->

    @$el.off("dragstart")

    @$el.find(".btn-group a").off("click")
    @$el.find(".zoom-slider")
      .off("change")
      .off("click")

    @$el.find(".tagbarItem input").off("click")

    @gui.deactivate()
    @tagbar.deactivate()
    @wheel.deactivate()

    @wheel.off("delta", app.view.overview.changeZoom)
    app.view.overview.off(this, "zoom", @zoom)


  zoom : (scaleValue, position) =>

    @graph.graphContainer.attr("transform", "scale( #{scaleValue} )")
    @trigger("view:zooming")
    @graph.drawProjects(scaleValue, [])
    @graph.drawProjects(scaleValue)


  initGraph : ->

    @domElement = d3.select(@el).select(".graph svg")
    @graphContainer = @domElement.append("svg:g")

    @projects = []
    console.log IMAGE_FOLDER

    @projectsCollection.forEach( (project) =>

      p =
        id:           project.get("id")
        name:         project.get("name")
        season:       project.get("season")
        year:         project.get("year")
        length:       project.get("length")
        participants: project.get("participants")
        image:        IMAGE_FOLDER.concat "#{project.get("name")[0].toLowerCase()}.png"
        width:        "100px"
        height:       "100px"
        tags:         [project.get("year")]

      @projects.push p
    )

    @graph = new ProjectGraph(@graphContainer, @domElement, @projects)








