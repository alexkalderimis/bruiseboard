React = require 'react'

console.log 'WELCOME!'

MilestoneProgress = React.createFactory require './ui/milestone-progress'
RepoStats = React.createFactory require './ui/repo-stats'
TravisBuild = React.createFactory require './ui/travis-build'

{initBuilds, advanceBuild} = require './demo/build-cycle'
{updateStats, getStats} = require './demo/stats'

{div} = React.DOM

ExampleBuilds = React.createFactory React.createClass

  render: -> div className: 'ui vertically divided grid',
    ((TravisBuild b) for b in @props.builds)

fake_milestones = require './json/fake-milestones.json'
fake_builds = require './json/fake-builds.json'

# Stats
fake_stats = getStats()
milestone_node = document.querySelector '#example-milestone'
stat_node = document.querySelector '#example-statistics'

React.render (MilestoneProgress milestones: fake_milestones), milestone_node

statsComponent = React.render (RepoStats fake_stats), stat_node

setInterval (-> statsComponent.setProps updateStats fake_stats), 3000

# Builds
build_node = document.querySelector '#example-builds'
initBuilds fake_builds

buildsComponent = React.render (ExampleBuilds builds: fake_builds), build_node

advanceBuilds = ->
  for b in fake_builds
    advanceBuild b
  buildsComponent.setProps builds: fake_builds

setInterval advanceBuilds, 1000

$('.ui.sticky').sticky context: '.main.container', offset: 50

$('.pointing.menu .item').on 'click', (e) ->
  a = $ e.target
  a.addClass 'active'
  a.siblings().removeClass 'active'
