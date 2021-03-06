# Description:
#   Remember
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot mem <keyword> - prints out saved resource
#   hubot get <keyword> - prints out saved resource
#   hubot get list - prints out saved keys
#   hubot rem <keyword> <resource> - saves resource to specified keyword
#   hubot set <keyword> <resource> - saves resource to specified keyword
#   hubot remove <keyword> - Removes a key-value pair
#
# Author:
#   snibbles

memremBrain = "memrem"

onGet = (msg) ->
  key = msg.match[2]
  brain = msg.robot.brain
  if old = oldWay(brain, key)
    saveAndRemoveOld(brain, key, old)
    msg.send old
  else if value = brainMatch(brain, key)
    msg.send value
  else
    msg.send "Couldn't find #{key}."

brainMatch = (brain, key) ->
  storage = (brain.get memremBrain) ? {}
  return storage[key]

oldWay = (brain, key) ->
  if old = brain.get "memrem_#{key}"
    return old
  return null

saveAndRemoveOld = (brain, key, value) ->
  storage = brain.get memremBrain
  storage[key] = value
  brain.set memremBrain, storage
  brain.remove "memrem_#{key}"

onSet = (msg) ->
  key = msg.match[2]
  value = msg.match[3]
  brain = msg.robot.brain
  storage = (brain.get memremBrain) ? {}
  storage[key] = value
  brain.set memremBrain, storage
  msg.send "saved #{value} as #{key}"

module.exports = (robot) ->
  robot.respond /(mem|get) (?!safesearch|list)([a-zA-Z0-9_-]*)$/i, onGet
  
  # (?:.|[\r\n]) is a non capturing group (?:), so that match[3] still matches the value
  # the . matches all characters except for new lines so the .|\r\n allows for multi line matching
  robot.respond /(rem|set) (?!safesearch|list)([a-zA-Z0-9_-]*) ((?:.|[\r\n])+)/i, onSet

  robot.respond /(mem|get) list$/i, (msg) ->
    storage = msg.robot.brain.get memremBrain
    msg.send Object.keys(storage).join(", ")

  robot.respond /remove (?!safesearch|list)([a-zA-Z0-9_-]*)$/i, (msg) ->
    key = msg.match[1]
    brain = msg.robot.brain
    storage = brain.get memremBrain
    delete storage[key]
    brain.set memremBrain, storage
    msg.send "Deleted #{key}."

