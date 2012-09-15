assert = require "assert"
{_}    = require "UnderscoreKit"

load      = require "load"
ephemeral = load "store/ephemeral/memory"

describe "store/ephemeral/memory", () ->
  beforeEach () -> @container = ephemeral()
  describe ".has", () ->
    it "should return false when we don't have the requested key", () ->
      assert.equal false, @container.has "a"

    it "should return true when we have the requested key", () ->
      @container.set "a", "v"
      assert.equal true, @container.has "a"

    describe "get", () ->
    it "should return an error case when we don't have the requested key", () ->
      [error, value] = @container.get "a"
      assert.equal true, !!error

    it "should return the correct value for the key we request", () ->
      @container.set "a", "v"
      [error, value] = @container.get "a"
      assert.equal "v", value

  describe "set", () ->
    it "should set the correct value for an unheard of key", () ->
      @container.set "a", "v"
      [error, value] = @container.get "a"
      assert.equal "v", value

    it "should set the correct value for a previously set key", () ->
      @container.set "a", "a"
      @container.set "a", "b"
      [error, value] = @container.get "a"
      assert.equal "b", value

  describe "unref", () ->
    it "should return an error case when unreferencing an invalid key", () ->
      [error, value] = @container.unref "a"
      assert.equal true, !!error

    it "should return value false when unreferencing an invalid key", () ->
      [error, value] = @container.unref "a"
      assert.equal false, value

    it "shouldn't return an error case when unreferencing a valid key", () ->
      @container.set "a", "v"
      @container.get "a"
      [error, value] = @container.unref "a"
      assert.equal false, error

    it "should return value true when unreferencing a valid key", () ->
      @container.set "a", "v"
      @container.get "a"
      [error, value] = @container.unref "a"
      assert.equal true, value