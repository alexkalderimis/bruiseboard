{randInt} = require './rand-tools'

exports.updateStats = (fake_stats) ->
  fake_stats.pulls += randInt -3, 3
  fake_stats.pulls = Math.max(0, fake_stats.pulls)
  fake_stats.forks += randInt 0, 4
  fake_stats.releases += randInt 0, 3
  fake_stats.issues += randInt -5, 5
  fake_stats.issues = Math.max 0, fake_stats.issues

  return fake_stats

exports.getStats = ->
  issues:   randInt 50, 100
  releases: randInt 25, 100
  pulls:    randInt 0, 15
  forks:    randInt 0, 15
