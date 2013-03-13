require.config(

  baseUrl : "/assets/javascripts"
  waitSeconds : 15

  paths :
    underscore : "lib/lodash-1.0.1"
    backbone : "lib/backbone-0.9.10"
    "backbone.wreqr" : "lib/backbone.wreqr-0.1.1"
    "backbone.babysitter" : "lib/backbone.babysitter-0.0.4"
    "backbone.marionette" : "lib/backbone.marionette-1.0.0.rc6"
    "backbone.deepmodel" : "lib/backbone.deepmodel-0.10.1"
    jquery : "lib/jquery-1.9.1"
    async : "lib/async-0.2.6"
    d3 : "lib/d3-3.0.8"


  shim :
    underscore :
      exports : "_"
    backbone :
      deps : [ "underscore" ]
      exports : "Backbone"
    d3 :
      exports : "d3"
    "backbone.deepmodel" :
      deps : [ "backbone", "underscore" ]
      exports : "Backbone.DeepModel"

)

define(
  "app"
  ["./lib/application", "backbone.deepmodel"]
  (Application) -> new Application()
)


require ["backbone", "app"], (Backbone, app) ->

  #app.on "start" : -> alert("Test")

  require [
    "sample"
  ], -> app.start( test : 123 )

  require [
    "testGraph"
  ], -> app.start()

