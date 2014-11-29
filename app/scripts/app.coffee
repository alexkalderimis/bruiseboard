React = require 'react'
data = require './json/dummy.json'

{div, h2, p, a} = React.DOM

COLORS =
  success: 'teal'
  error: 'black'
  failure: 'red'
  building: 'yellow'

JobView = React.createFactory React.createClass

  render: ->
    a className: "ui #{ COLORS[@props.status] } label",
      @props.name

BuildView = React.createFactory React.createClass

  getColour: ->
    return COLORS[@props.build.status]

  render: ->
    jobs = for job, i in @props.build.jobs
      job.key = i
      JobView job

    div className: "secondary #{ @getColour() } row",
      div className: 'five wide column',
        h2 {}, @props.build.repo
        p {},
          @props.build.commit.author,
          ': '
          @props.build.commit.message
      div className: 'seven wide column',
        div className: 'ui huge labels',
          jobs.reverse()
      div className: 'right aligned four wide column',
        div className: 'ui large yellow tag label',
          @props.build.branch,
          '#',
          @props.build.commit.hash,

BuildsView = React.createFactory React.createClass

  getInitialState: -> {}

  render: ->
    builds = (BuildView(key: i, build: build) for build, i in @props.builds)
    div className: 'ui vertically padded page grid',
      builds

React.render (BuildsView builds: data), document.querySelector('#app')


