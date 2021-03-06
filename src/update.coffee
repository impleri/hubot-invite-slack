config = require "./config"
filters = require "./filters"
require "array.prototype.find"

# Singleton instance
instance = null

class InviteUpdate
  users = []

  constructor: (@robot) ->
    @users = Object.keys(@robot.brain.users()).map (key) =>
      @robot.brain.users()[key]
    @robot.brain.set config.brainKey, @run @robot.brain.get config.brainKey
    null

  run: (invites = []) ->
    newInvites = []
    newInvites.push @invitation invite for invite in invites
    newInvites

  invitation: (invite) ->
    newInvite = @user invite
    newInvite.time = invite.time
    newInvite.sender = invite.sender
    newInvite

  user: (user) ->
    fullUser =
      name: user
      email_address: null
      id: null

    user = fullUser if typeof user is "string"

    field = "name" if user.name
    field = "email_address" if user.email_address
    field = "id" if user.id

    if field?
      filter = filters.userByField field, user[field]
      realUser = @users.find filter
      user = realUser if realUser

    user

module.exports = (robot) ->
  null unless robot?
  instance ?= new InviteUpdate robot
  instance
