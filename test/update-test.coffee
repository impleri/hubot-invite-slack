chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect

UpdateClass = require "../src/update"

robot =
  brain:
    data: {}
    get: sinon.stub()
    set: sinon.stub()
    users: sinon.stub()

expectedIdUser =
  id: 10
  name: "invited-person"
  email_address: "person@example.com"

expectedNameUser =
  id: 30
  name: "username"
  email_address: "differnt@example.com"

expectedEmailUser =
  id: 60
  name: "different-person"
  email_address: "user@example.com"

expectedStringUser =
  id: 70
  name: "another-user"
  email_address: "another@example.org"

users =
  10: expectedIdUser
  20:
    id: 20
    name: "existing-user"
    email_address: "existing@example.org"
  30: expectedNameUser
  40:
    id: 40
    name: "found-user"
    email_address: "found@example.org"
  50:
    id: 50
    name: "new-user"
    email_address: "newb@example.com"
  60: expectedEmailUser
  70: expectedStringUser

describe "updater", ->
  @updater = null

  beforeEach ->
    @robot = robot
    @robot.brain.users.returns users

  it "constructs", ->
    @robot = robot
    @robot.brain.get.returns []

    @updater = UpdateClass @robot
    expect(@robot.brain.get).to.have.been.calledWith sinon.match.string
    expect(@robot.brain.set).to.have.been.calledWith sinon.match.string, []


  it "runs for every existing entry", ->
    oldInvite = "old-invite"
    newInvite = "new-invite"
    updateInvite = sinon.stub @updater, "invitation"
    updateInvite.returns newInvite

    response = @updater.run [oldInvite]
    expect(updateInvite).to.have.been.calledWith oldInvite
    expect(response).to.have.members [newInvite]
    updateInvite.restore()

  it "updates an invitation", ->
    sender = "new-sender"
    oldInvite =
      name: "old-invite"
      time: "old"
      sender: sender
    newInvite =
      name: "new-invite"
      time: "new"
      sender: sender

    updateUser = sinon.stub @updater, "user"
    updateUser.returns newInvite

    response = @updater.invitation oldInvite

    expect(updateUser).to.have.been.calledWith oldInvite
    expect(response).to.deep.equal newInvite
    updateUser.restore()

  it "does not update user if missing name, email, and id", ->
    testUser =
      blah: false

    response = @updater.user testUser
    expect(response).to.equal testUser

  it "updates user by name", ->
    testUser =
      name: "username"
      email_address: null
      id: null

    response = @updater.user testUser
    expect(response).to.deep.equal expectedNameUser

  it "updates user by string", ->
    response = @updater.user "another-user"
    expect(response).to.deep.equal expectedStringUser

  it "updates user by email", ->
    testUser =
      name: "username"
      email_address: "user@example.com"
      id: null

    response = @updater.user testUser
    expect(response).to.deep.equal expectedEmailUser

  it "updates user by id", ->
    testUser =
      name: "username"
      email_address: "user@example.com"
      id: 10

    response = @updater.user testUser
    expect(response).to.deep.equal expectedIdUser
