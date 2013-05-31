### define
jquery : $
###


class Tagbar

  domElement : null
  taglist = [
    {type :"project_partner", name : "SAP"},
    {type :"date", name : "2013"},
    {type :"date", name : "2012"},
    {type :"date", name : "2011"},
    {type :"date", name : "2010"},
    {type :"branch", name : "Health"},
    {type :"branch", name : "Energy"},
  ]


  constructor : () ->

    @availableTags = taglist

    domElement = $("<div/>")
    @domElement = domElement

    @populateTagForm()


  setResized : (func) ->

    @onResized = func


  populateTagForm : ->

    $branchTaglist = $("#branchtags")
    $dateTaglist = $("#datetags")
    $partnerTaglist = $("#partnertags")

    for tag in @availableTags
      tagName = tag.name
      tagType = tag.type

      $container = $("<div>",
        class: "tagbarItem"
      )

      $checkbox = $("<input>",
        type: "checkbox"
        name: tagName
        value: tagName
        )

      label = document.createElement("label") #jquery!
      label.innerHTML = tagName

      # $label = $("label")
      # $label.text tagName

      $container.append $checkbox
      $container.append label

      switch tagType
        when "date" then $dateTaglist.append $container
        when "project_partner" then $partnerTaglist.append $container
        when "branch" then $branchTaglist.append $container
        else console.log "tag with strange type"


  destroy : ->

  activate : ->

  deactivate : ->





