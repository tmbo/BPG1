### define
jquery : $
underscore : _
./artifact : Artifact
###


class ArtifactFinder

  GROUP_NAMES : ["Dropbox", "Incom", "FileShare"]
  TAB_PREFIX : "tab"

  domElement : null
  groups : null
  artifacts : []

  SAMPLE_ARTIFACT : {
    name:"test1"
    id : 12345
    source : "Dropbox"
    resources : [
      {type :"thumbnail", id : 123, path : "assets/images/thumbnails/0.png"}
      {type :"thumbnail", id : 456, path : "assets/images/thumbnails/1.png"}
      {type :"thumbnail", id : 789, path : "assets/images/thumbnails/2.png"}
      {type :"thumbnail", id : 112, path : "assets/images/thumbnails/3.png"}
      {type :"original",  id : 345, path : "assets/images/thumbnails/fail.png"}
    ]
  }

  constructor : () ->

    @groups = []
    @artifactComponents = []

    domElement = $('<div/>', {

    })

    slider = $("<input/>", {
      id : "defaultSlider"
      type : "range"
      min : "1"
      max : "500"
      value: "40"
    })

    domElement.append(slider)

    @artifacts.push new Artifact( @SAMPLE_ARTIFACT, -> 64 )
    artifact = @SAMPLE_ARTIFACT

    @createGroups(domElement, @GROUP_NAMES)

    func = -> this.value
    x = _.bind(func, slider[0])

    artifactC = new Artifact(
      artifact
      x
    )
    @artifactComponents.push artifactC

    slider.on(
      "change"
      => artifactC.resize()
    )

    domElement.append(artifactC.domElement)

    group = _.find(@groups, (g) => g.name is artifact.source)
    group.div.append(artifactC.domElement)


    @domElement = domElement


  setResized : (func) ->
    @onResized = func



  destroy : ->

  activate : ->

  deactivate : ->

  getArtifact : (id) =>

    for artifact in @artifacts
      if artifact.id = id
        return _.cloneDeep(artifact)


  pluginDocTemplate : _.template """
    <div class="tabbable tabs-top">
      <ul class="nav nav-tabs">
        <% groupNames.forEach(function (group) { %>
          <li>
            <a data-toggle="tab"
              href="#tab<%= group %>">
              <%= group %>
            </a>
          </li>
        <% }) %>
      </ul>
      <div class="tab-content">
        <% groupNames.forEach(function (group) { %>
          <div class="tab-pane" id="tab<%= group %>">
            <p>
              <%= group %>test
            </p>
          </div>
        <% }) %>
      </div>
    </div>
  """


  createGroups : (parent, groupNames) ->

    { groups } = @

    tabs = @pluginDocTemplate { groupNames }
    parent.append(tabs)
    for name in groupNames
      groups.push { name: name, div: parent.find("#tab#{name}")}

