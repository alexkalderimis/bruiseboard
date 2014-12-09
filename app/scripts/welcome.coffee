React = require 'react'

console.log 'WELCOME!'

MilestoneProgress = React.createFactory require './ui/milestone-progress'
RepoStats = React.createFactory require './ui/repo-stats'

fake_milestones = require './json/fake-milestones.json'

fake_stats =
  issues:   Math.round(Math.random() * 100)
  releases: Math.round(Math.random() * 100)
  pulls: Math.round(Math.random() * 15)
  forks: Math.round(Math.random() * 20)

milestone_node = document.querySelector '#example-milestone'
stat_node = document.querySelector '#example-statistics'

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
