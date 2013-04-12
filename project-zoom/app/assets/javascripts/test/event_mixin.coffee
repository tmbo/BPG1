### define
lib/event_mixin : EventMixin
lib/chai : chai
###

describe "EventMixin", ->

  beforeEach ->

    @dummyDispatcher = { register : (->) , unregister : (->) }
    @eventMixin = EventMixin.extend({}, @dummyDispatcher)
    @spy = chai.spy()
    @self = {}


  describe "#on / #off", ->

    it "should work", ->

      @eventMixin.on(@self, "test", @spy)
      @eventMixin.trigger("test", "testArg")

      @spy.should.have.been.called.once

      @eventMixin.off(@self, "test", @spy)
      @eventMixin.trigger("test", "testArg")

      @spy.should.have.been.called.once


    it "should work without self-reference", ->

      @eventMixin.on("test", @spy)
      @eventMixin.trigger("test", "testArg")

      @spy.should.have.been.called.once

      @eventMixin.off("test", @spy)
      @eventMixin.trigger("test", "testArg")

      @spy.should.have.been.called.once


    it "should work with an array of callbacks", ->

      spy2 = chai.spy()

      @eventMixin.on(@self, "test", [ @spy, spy2 ])
      @eventMixin.trigger("test", "testArg")

      @spy.should.have.been.called.once
      spy2.should.have.been.called.once

      @eventMixin.off(@self, "test", [ @spy, spy2 ])
      @eventMixin.trigger("test", "testArg")

      @spy.should.have.been.called.once
      spy2.should.have.been.called.once


    it "should work with a map of callbacks", ->

      spy2 = chai.spy()

      @eventMixin.on(@self, 
        "test" : [ @spy, spy2 ]
        "test2" : @spy
      )
      @eventMixin.trigger("test", "testArg")
      @eventMixin.trigger("test2", "testArg")

      @spy.should.have.been.called.twice
      spy2.should.have.been.called.once

      @eventMixin.off(@self, 
        "test" : [ @spy, spy2 ]
        "test2" : @spy
      )
      @eventMixin.trigger("test", "testArg")
      @eventMixin.trigger("test2", "testArg")

      @spy.should.have.been.called.twice
      spy2.should.have.been.called.once


    it "should only remove first callback", ->

      @eventMixin.on(@self, "test", @spy)
      @eventMixin.on(@self, "test", @spy)
      @eventMixin.trigger("test", "testArg")

      @spy.should.have.been.called.twice

      @eventMixin.off(@self, "test", @spy)
      @eventMixin.trigger("test", "testArg")

      @spy.should.have.been.called.exactly(3)


  describe "#times", ->

    it "should only be called 3-times", ->

      @eventMixin.times(@self, "test", @spy, 3)

      for i in [1..4]
        @eventMixin.trigger("test", "testArg")

      @spy.should.have.been.called.exactly(3)


  describe "#hasCallbacks", ->

    it "should have callbacks", ->

      @eventMixin.on(@self, "test", @spy)
      @eventMixin.hasCallbacks("test").should.be.true



  describe "#isolatedExtend", ->

    it "should work with scrambled function names", ->

      @eventMixin = EventMixin.isolatedExtend({}, @dummyDispatcher)
      @eventMixin.addEventListener = @eventMixin.on
      delete @eventMixin.on
      delete @eventMixin.dispatcher

      @eventMixin.addEventListener(@self, test : @spy )
      @eventMixin.trigger("test", "testArg")
      @eventMixin.off(@self, "test", @spy)

      @spy.should.have.been.called.once
