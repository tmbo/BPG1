### define
d3 : d3
lib/event_mixin : EventMixin
./process_view/graph : Graph
./process_view/node : Node
./process_view/behavior/connect_behavior : connectBehavior
./process_view/behavior/drag_behavior : dragBehavior
../component/project : Project
###

class ProjectGraph extends Graph

  SAMPLE_PROJECT_1 =
    name : "Test 1"
    tags : [
      {type : "project_partner", name : "SAP"},
      {type : "date", name : "2013"},
      {type : "branch", name : "Health"},
    ]
    img : null
    node : null

  SAMPLE_PROJECT_2 =
    name : "Test 2"
    tags : [
      {type : "project_partner", name : "Siemens"},
      {type : "date", name : "2013"},
      {type : "branch", name : "Diabetes"},
    ]
    img : "http://cdn.arstechnica.net/wp-content/uploads/2012/10/06_Place_20773_1_Mis.jpg"
    node : null

  SAMPLE_PROJECT_3 =
    name : "Test 3"
    tags : [
      {type : "project_partner", name : "Janssen"},
      {type : "branch", name : "Energy"},
    ]
    img : "http://www.thinkstockphotos.com/CMS/StaticContent/WhyThinkstockImages/Best_Images.jpg"
    node : null

  SAMPLE_PROJECTS = [SAMPLE_PROJECT_1, SAMPLE_PROJECT_2, SAMPLE_PROJECT_3]


  constructor : (@container, @svg, @layouter) ->

    super(@container)

    @selectedTags = []
    @clusters = []
    @projects = []

    EventMixin.extend(this)
    @initArrowMarkers()
    @initProjects()

    @circles = @svg.append("svg:g").selectAll("circle")

    # @currentBehavior = new connectBehavior(@)
    # @currentBehavior.activate()


  initProjects : ->

    for p in SAMPLE_PROJECTS
      project = new Project(p)

      @projects.push project

    pos_x = 20
    pos_y = 20

    for p in @projects
      node = @addNode(pos_x, pos_y)

      p.setNode node

      pos_x += 70
      pos_y += 70


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


  addNode : (x, y, nodeId, artifact) =>

    id = nodeId ? @nodeId++

    node = new Node(
      x,
      y,
      id,
      artifact
    )

    @nodes.push node
    @drawNodes()

    node      # return node


  changeBehavior : (behavior) ->

    @currentBehavior.deactivate()
    @currentBehavior = behavior
    @currentBehavior.activate()


######################### Drawing: #########################


  drawClusters : ->

    @circles = @circles.data(@clusters, (data) -> data.id)
    g = @circles.enter().append("svg:g")
    g.append("svg:text")
      .attr(
        id: "text1"
        x: (d) -> d.position[2]
        y: (d) -> d.position[3]
        id: (d) -> "label_#{d.name}"
        class: "label"
      )
      .text( (d) -> d.name )
    g.append("svg:circle")
      .attr(
        r: 200
        cx: (d) -> d.position[0]
        cy: (d) -> d.position[1]
        id: (d) -> "cluster_#{d.name}"
        fill: (d) -> d.color
        "fill-opacity": .5
        "data-pos": location
      )

    @circles.exit().remove()


######################### Arranging: #########################

  updateClusters : (checkbox) =>

    location =
      0: [300, 200, 250, 50]
      1: [550, 200, 550, 50]
      2: [425, 400, 425, 575]

    color =
      0: "steelblue"
      1: "yellow"
      2: "forestgreen"

    if $(checkbox).is(":checked")
      @selectedTags.push checkbox.value
    else
      @selectedTags = (tag for tag in @selectedTags when tag isnt checkbox.value)

    @clusters = []

    if @selectedTags.length <= 3
      for t, index in @selectedTags
        cluster =
          position: location[index]
          color: color[index]
          name: t
          id: t

        @clusters.push cluster

    @drawClusters()

    @arrangeProjectsInClusters()


  arrangeProjectsInClusters : () ->

    # left = right = bottom = lr = lb = br = middle = no_cluster = []

    projectClusters =
      "left" : []
      "right" : []
      "bottom" : []
      "lr" : []
      "lb" : []
      "br" : []
      "middle" : []
      "no_cluster" : []

    for p in @projects
      selectedProjectTags = []
      for t in p.tags
        selectedProjectTags.push t.name if t.name in @selectedTags

      assignedCluster = @getAssignedCluster selectedProjectTags

      projectClusters[assignedCluster].push p.node

    @layouter.arrangeNodesInClusters(projectClusters)

    # @resizeCircles all
    # @arrangeProjects all

    # @layouter.arrangeInSquare()
    # @layouter.resizeCircle()
      # @updateNode(p, selectedProjectTags)


  resizeAllCircles : () ->

  arrangeAllProjects : () ->

######################### Calculating: #########################

  getAssignedCluster : (assignedTags) ->

    positions = []

    for c in assignedTags
      [cluster] = assignedTags.filter (c) -> c[0][0][0].id == "cluster_#{c}"
      positions.push $(cluster).data("pos")

    if "left" in positions
      if "right" in positions
        if "bottom" in positions
          return "middle"
        else return "lr"
      else if "bottom" in positions
        return "lb"
      else return "left"
    else if "right" in positions
      if "bottom" in positions
        return "br"
      else return "right"
    else if "bottom" in positions
      return "bottom"
    else return "no_cluster"








