assert = require "assert"
{_}    = require "UnderscoreKit"

load        = require "load"
courier_gen = load "courier"

describe "courier", () ->
  beforeEach () -> @courier = courier_gen()
  describe ".get", () ->
    it "should add a subscriber for id '1' on key 'a'", () ->
      assert.equal 1, @courier.get 1, "a", _.identity

    it "should not add another subscriber for id '1' on key 'a'", () ->
      @courier.get 1, "a", _.identity
      assert.equal 1, @courier.get 1, "a", _.identity

    it "should add a subscriber for id '2' on key 'a'", () ->
      @courier.get 1, "a", _.identity
      assert.equal 2, @courier.get 2, "a", _.identity

    it "should not add another subscriber for id '2' on key 'a'", () ->
      @courier.get 2, "a", _.identity
      assert.equal 1, @courier.get 2, "a", _.identity

    it "should add a subscriber for id '1' on key 'b'", () ->
      assert.equal 1, @courier.get 1, "b", _.identity

    it "should not add another subscriber for id '1' on key 'b'", () ->
      @courier.get 1, "b", _.identity
      assert.equal 1, @courier.get 1, "b", _.identity

    it "should add a subscriber for id '2' on key 'b'", () ->
      @courier.get 1, "b", _.identity
      assert.equal 2, @courier.get 2, "b", _.identity

    it "should not add another subscriber for id '2' on key 'b'", () ->
      @courier.get 2, "b", _.identity
      assert.equal 1, @courier.get 2, "b", _.identity

  describe ".unget", () ->
    it "should return false when we remove a ref that doesn't exist", () ->
      assert.equal false, @courier.unget 1, "a"

    it "should return true when we remove a propper ref", () ->
      @courier.get 1, "a", _.identity
      assert.equal true, @courier.unget 1, "a"

    it "should emit an unused event when a key has no more refs", (done) ->
      @courier.get 1, "a", _.identity
      @courier.on "unused", (key) -> done()
      @courier.unget 1, "a"

  describe ".deliver", () ->
    it "should return 0 if no subscribers are present", () ->
      assert.equal 0, @courier.deliver "k", "v"

    it "should return 1 if only one subscriber is present", () ->
      @courier.get 1, "k", _.identity
      assert.equal 1, @courier.deliver "k", "v"
      @courier.unget 1, "k"

    it "should call the subscriber method when present", (done) ->
      @courier.get 1, "k", (v) -> done()
      assert.equal 1, @courier.deliver "k", "v"
      @courier.unget 1, "k"