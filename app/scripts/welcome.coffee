React = require 'react'

console.log 'WELCOME!'

MilestoneProgress = React.createFactory require './ui/milestone-progress'
RepoStats = React.createFactory require './ui/repo-stats'
TravisBuild = React.createFactory require './ui/travis-build'

{div} = React.DOM

ExampleBuilds = React.createFactory React.createClass

  render: -> div className: 'ui vertically divided grid',
    ((TravisBuild b) for b in @props.builds)

randInt = (low, high) ->
  span = high - low
  Math.round(Math.random() * span) + low

fake_milestones = require './json/fake-milestones.json'
fake_builds = require './json/fake-builds.json'

fake_stats =
  issues:   randInt 50, 100
  releases: randInt 25, 100
  pulls:    randInt 0, 15
  forks:    randInt 0, 15

milestone_node = document.querySelector '#example-milestone'
stat_node = document.querySelector '#example-statistics'
build_node = document.querySelector '#example-builds'

React.render (MilestoneProgress milestones: fake_milestones), milestone_node

statsComponent = React.render (RepoStats fake_stats), stat_node

updateStats = ->
  fake_stats.pulls += randInt -3, 3
  fake_stats.pulls = Math.max(0, fake_stats.pulls)
  fake_stats.forks += randInt 0, 4
  fake_stats.releases += randInt 0, 3
  fake_stats.issues += randInt -5, 5
  fake_stats.issues = Math.max 0, fake_stats.issues

  statsComponent.setProps fake_stats

setInterval updateStats, 3000

one_week = (7 * 24 * 60 * 60 * 1000)
one_week_ago = (new Date).getTime() - one_week

for b in fake_builds
  b.number = randInt 0, 100
  b.startedAt = new Date(Math.round(Math.random() * one_week) + one_week_ago)
  b.requestBuildUpdate = ->
  b.requestJobUpdate = ->

buildsComponent = React.render (ExampleBuilds builds: fake_builds), build_node

advanceJob = (j) ->
  if j.status is 'queued'
    if Math.random() > 0.7
      j.status = 'started'
  else if j.status is 'started'
    r = Math.random()
    if r < 0.6
      j.status = 'started'
    else if r < 0.65
      j.status = 'errored'
    else if r < 0.75
      j.status = 'failed'
    else
      j.status = 'passed'

chars = '0123456789abcdef'

getHash = ->
  idxs = (randInt 0, 15 for i in [0 .. 7])
  (chars[i] for i in idxs)

resetBuild = (b) ->
  b.number++
  b.status = 'queued'
  b.commit.hash = getHash()
  for j in b.jobs
    j.status = 'queued'

advanceBuild = (b) ->
  if b.status is 'queued'
    if Math.random() > 0.5
      b.status = 'started'
  
  if b.status is 'started'
    for job in b.jobs
      advanceJob job

    if not (b.jobs.some (j) -> j.status in ['queued', 'started']) # All are done
      if (b.jobs.some (j) -> j.status is 'errored')
        b.status = 'errored'
      else if (b.jobs.some (j) -> j.status is 'failed')
        b.status = 'failed'
      else
        b.status = 'passed'
      setTimeout resetBuild.bind(null, b), randInt 5000, 10000

advanceBuilds = ->
  for b in fake_builds
    advanceBuild b
  buildsComponent.setProps builds: fake_builds

setInterval advanceBuilds, 1000

$('.ui.sticky').sticky context: '.main.container', offset: 50
