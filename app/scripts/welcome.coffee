React = require 'react'

console.log 'WELCOME!'

MilestoneProgress = React.createFactory require './ui/milestone-progress'
RepoStats = React.createFactory require './ui/repo-stats'
TravisBuild = React.createFactory require './ui/travis-build'

{div} = React.DOM

ExampleBuilds = React.createFactory React.createClass

  render: -> div className: 'ui vertically divided grid',
    ((TravisBuild b) for b in @props.builds)

fake_milestones = require './json/fake-milestones.json'
fake_builds = require './json/fake-builds.json'

fake_stats =
  issues:   Math.round(Math.random() * 100)
  releases: Math.round(Math.random() * 100)
  pulls: Math.round(Math.random() * 15)
  forks: Math.round(Math.random() * 20)

milestone_node = document.querySelector '#example-milestone'
stat_node = document.querySelector '#example-statistics'
build_node = document.querySelector '#example-builds'

React.render (MilestoneProgress milestones: fake_milestones), milestone_node

statsComponent = React.render (RepoStats fake_stats), stat_node

updateStats = ->
  fake_stats.pulls += (Math.round(Math.random() * 6) - 3)
  fake_stats.pulls = Math.max(0, fake_stats.pulls)
  fake_stats.forks += Math.round(Math.random() * 4)
  fake_stats.releases += Math.round(Math.random() * 3)
  fake_stats.issues += (Math.round(Math.random() * 10) - 5)

  statsComponent.setProps fake_stats

setInterval updateStats, 3000

one_week = (7 * 24 * 60 * 60 * 1000)
one_week_ago = (new Date).getTime() - one_week

for b in fake_builds
  b.startedAt = new Date(Math.round(Math.random() * one_week) + one_week_ago)
  b.requestBuildUpdate = ->

React.render (ExampleBuilds builds: fake_builds), build_node

$('.ui.sticky').sticky context: '.main.container', offset: 50
