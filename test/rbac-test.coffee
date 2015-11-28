chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"

expect = chai.expect

describe "rbac", ->
  beforeEach ->
    @robot =
      brain:
        on: sinon.spy()
      respond: sinon.spy()
      hear: sinon.spy()
      listenerMiddleware: sinon.spy (context, next, done) =>
          # Do nothing

    require("../src/rbac")(@robot)

  it "registers a respond listener", ->
    expect(@robot.respond).to.have.been.calledWith(/auth me/i)
    expect(@robot.respond).to.have.been.calledWith(/auth block (.+) (.+)/i)
    expect(@robot.respond).to.have.been.calledWith(/auth unblock (.+) (.+)/i)
    expect(@robot.respond).to.have.been.calledWith(/auth assign (.+) (.+)/i)
    expect(@robot.respond).to.have.been.calledWith(/auth unassign (.+) (.+)/i)
    expect(@robot.respond).to.have.been.calledWith(/auth default (.+)/i)
    expect(@robot.respond).to.have.been.calledWith(/auth ids/i)
    expect(@robot.respond).to.have.been.calledWith(/auth roles/i)

  it "registers a listener middleware", ->
    expect(@robot.listenerMiddleware).to.have.been.called

  it "registers a brain event listener", ->
    expect(@robot.brain.on).to.have.been.calledWith("loaded")
