chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"

expect = chai.expect

describe "authority", ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()
      listenerMiddleware: sinon.spy (context, next, done) =>
          # Do nothing

    require("../src/authority")(@robot)

  it "registers a respond listener", ->
    expect(@robot.respond).to.have.been.calledWith(/auth me/i)
    expect(@robot.respond).to.have.been.calledWith(/auth block (.+) (.+)/i)
    expect(@robot.respond).to.have.been.calledWith(/auth unblock (.+) (.+)/i)
    expect(@robot.respond).to.have.been.calledWith(/auth assign (.+) (.+)/i)
    expect(@robot.respond).to.have.been.calledWith(/auth unassign (.+) (.+)/i)
    expect(@robot.respond).to.have.been.calledWith(/auth default (.+)/i)

  it "registers a listener middleware", ->
    expect(@robot.listenerMiddleware).to.have.been.called