# Description:
#   Team Roles
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot roles - Show assigned roles
#   hubot roles list - List available roles
#   hubot roles add <role> - Add a role
#   hubot roles rm <role> - remove a role
#   hubot roles set <comma separated roles> - Set all roles at once
#   hubot roles people - List people
#   hubot roles people add <name> - Add a person
#   hubot roles people rm <name>- Remove a person
#   hubot roles people set <comma separated people> - Set all people at once
#   hubot roles shuffle - Randomly assign people to roles
#
# Notes:
#
# Author:
#   nwest

_ = require 'underscore'

rolesKey = (room) ->
  "roles-#{room}"

peopleKey = (room) ->
  "roles-people-#{room}"

currentRolesKey = (room) ->
  "roles-current-#{room}"

module.exports = (robot) ->
  robot.respond /roles$/i, (msg) ->
    currentRoles = robot.brain.get(currentRolesKey(msg.envelope.room))
    msg.send prettyObjectString(currentRoles)

  robot.respond /roles list/i, (msg) ->
    roles = robot.brain.get(rolesKey(msg.envelope.room))
    if !roles or _.isEmpty(roles)
      msg.send "None"
    else
      msg.send prettyArrayString(roles)

  robot.respond /roles add (.*)/i, (msg) ->
    newRoles = parseCommaSeparatedString(msg.match[1])
    
    key = rolesKey(msg.envelope.room)
    roles = robot.brain.get(key)
    if !roles or _.isEmpty(roles)
      roles = []

    roles.push role for role in newRoles

    robot.brain.set(key, roles)
    msg.send prettyArrayString(roles)

  robot.respond /roles rm (.*)/i, (msg) ->
    rolesToRemove = parseCommaSeparatedString(msg.match[1])
    rolesKey = rolesKey(msg.envelope.room)
    roles = robot.brain.get(rolesKey)

    newRoles = removeObjects(roles, rolesToRemove)
    robot.brain.set(rolesKey, newRoles)
    msg.send prettyArrayString(newRoles)

  robot.respond /roles set (.*)/i, (msg) ->
    roles = parseCommaSeparatedString(msg.match[1])
    rolesKey = rolesKey(msg.envelope.room)
    robot.brain.set(rolesKey, roles)
    msg.send prettyArrayString(roles)

  robot.respond /roles shuffle/i, (msg) ->
    roles = robot.brain.get rolesKey(msg.envelope.room)
    people = robot.brain.get peopleKey(msg.envelope.room)

    if roles.length > people.length
      msg.send "Not enough people to cover all roles"
    else
      newRoles = _.object(roles, _.sample(people, roles.length))
      robot.brain.set(currentRolesKey(msg.envelope.room), newRoles)
      msg.send prettyObjectString(newRoles)

  robot.respond /roles people$/i, (msg) ->
    people = robot.brain.get peopleKey(msg.envelope.room)
    if !people or _.isEmpty(people)
      msg.send "None"
    else
      msg.send prettyArrayString(people)

  robot.respond /roles people add (.*)/i, (msg) ->
    newPeople = parseCommaSeparatedString(msg.match[1])
    peopleKey = peopleKey(msg.envelope.room)
    people = robot.brain.get(peopleKey)
    if !people
      people = []

    people.push person for person in newPeople
    robot.brain.set(peopleKey, people)
    msg.send prettyArrayString(people)
    
  robot.respond /roles people rm (.*)/i, (msg) ->
    peopleToRemove = parseCommaSeparatedString(msg.match[1])
    peopleKey = peopleKey(msg.envelope.room)
    people = robot.brain.get(peopleKey)

    newPeople = removeObjects(people, peopleToRemove)
    robot.brain.set(peopleKey, newPeople)
    msg.send prettyArrayString(newPeople)
  
  robot.respond /roles people set (.*)/i, (msg) ->
    people = parseCommaSeparatedString(msg.match[1])
    peopleKey = peopleKey(msg.envelope.room)
    robot.brain.set(peopleKey, people)
    msg.send prettyArrayString(people)

  prettyObjectString = (object) ->
    _.map(object, (key, value) -> "#{value}: #{key}").join("\n")

  prettyArrayString = (array) ->
    array.join(", ")

  parseCommaSeparatedString = (string) ->
    string.split(/\s*,\s*/)

  removeObjects(source, itemsToRemove) ->
    _.reject(source, (item) ->
      itemsToRemove.indexOf(item) > -1)
