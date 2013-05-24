### define
jquery : $
###

class GUI

  constructor : ->

    @initToolbar()
    @initSVG()
    @initSideBar()
    @initToggle()


  initSVG : ->

    @svg = d3.select(".graph")
      .append("svg")
      .attr("width", $(".graph").width())
      .attr("pointer-events", "all")

    $(window).resize(
      => @svg.attr("height", $(window).height() - $(".graph").offset().top - 30)
    ).resize()


  initToolbar : ->

    $('.btn-group .btn').on "click", (event) ->
      $('.btn-group .btn').removeClass('active')

      $this = $(@)
      unless $this.hasClass('active')
        $this.addClass('active')

      event.preventDefault()


  initSideBar : ->

    $(".side-bar").css("height", @height)


  initToggle : ->

    $("a.toggles").click ->
      $("a.toggles i").toggleClass "icon-chevron-left icon-chevron-right"
      $("#artifact-finder").animate
        width: "toggle"
      , 100
      $("#main").toggleClass "span12 span8"
