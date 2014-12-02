React = require 'react'
data = require './json/dummy.json'

travis = require './services/travis'

{div, h2, span, p, a, i} = React.DOM

console.log i

COLORS =
  passed: 'teal'
  error: 'black'
  failure: 'red'
  building: 'yellow'

ICONS =
  error: 'bug'
  building: 'wait'
  passed: 'checkmark'
  failure: 'remove'

JobView = React.createFactory React.createClass

  getInitialState: -> {}

  componentDidMount: ->
    if @props.job?
      travis.get_job @props.job, (err, resp, body) =>
        if err
          @setState err: err
        else
          data = JSON.parse body
          @setState data

  render: ->
    if @state.job?
      {name, status} = @state.job
    else
      {status, status} = @props.job

    if name?
      a className: "ui #{ COLORS[status] } label",
        name
    else
      span()


BuildView = React.createFactory React.createClass

  getColour: -> COLORS[@props.build.status]

  render: ->
    jobs = for job, key in @props.build.jobs
      JobView {job, key}

    div className: "secondary #{ @getColour() } row",
      div className: 'five wide column',
        h2 {},
          i className: "#{ ICONS[@props.build.status] } icon"
          @props.build.repo
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
          @props.build.commit.hash.slice(0, 5),

Loader = React.createFactory React.createClass

  render: ->
    div className: 'ui active dimmer',
      div className: "ui #{ @props.size } text loader",
        @props.text

BuildsView = React.createFactory React.createClass

  getInitialState: -> {}

  componentDidMount: ->
    getBuilds = =>
      @props.getBuilds (builds) => @setState builds: builds.concat(data)
    @interval = setInterval getBuilds, 60000
    getBuilds()

  componentWillUnmount: ->
    clearInterval @interval

  render: ->
    content = if @state.builds
      builds = ((BuildView {build, key}) for build, key in @state.builds)
    else
      (Loader text: 'fetching data', size: 'large')

    div className: 'ui vertically padded page grid',
      content

# TODO - replace with backbone model powered controllers.
getBuilds = (cb) ->
  travis.get_build 'alexkalderimis/intermine', (err, build) ->
    if err
      throw err
    cb [build]

React.render (BuildsView {getBuilds}), document.querySelector('#app')
