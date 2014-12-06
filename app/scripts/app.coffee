React = require 'react'
data = require './json/dummy.json'
repos = require './json/repos.json'

travis = require './services/travis'

{div, h2, span, p, a, i} = React.DOM

COLORS =
  passed: 'teal'
  error: 'black'
  failed: 'red'
  started: 'yellow'
  building: 'yellow'

ICONS =
  error: 'bug'
  started: 'wait'
  building: 'wait'
  passed: 'checkmark'
  failed: 'remove'

JobView = React.createFactory React.createClass

  getInitialState: -> {job: {}}

  componentDidMount: ->
    getData = => travis.get_job @props.job, (err, job) =>
      if err
        @setState err: err
      else
        @setState job: job
        if job.status in ['failed', 'passed', 'errored']
          clearInterval @interval
          @interval = setInterval getData, (3 * 60 * 1000)

    @interval = setInterval getData, (30 * 1000)
    getData()

  componentWillUnmount: -> clearInterval @interval

  render: ->
    {name, status} = @state.job

    if name?
      a className: "ui right floated #{ COLORS[status] } label",
        name
    else
      span()


BuildView = React.createFactory React.createClass

  getInitialState: ->
    jobs: []
    status: 'fetching'
    commit:
      author: 'unknown'
      message: 'none'
      hash: ''

  componentDidMount: ->
    getData = => travis.get_build @props.repo, (err, build) =>
      if err?
        return console.error err
      @setState build
      # Move to less frequent updates if the build is finished
      if build.status in ['failed', 'passed', 'errored']
        clearInterval @interval
        @interval = setInterval getData, (3 * 60 * 1000)

    @interval = setInterval getData, (30 * 1000)
    getData()

  componentWillUnmount: -> clearInterval @interval

  getColour: -> COLORS[@state.status]

  render: ->
    if @state.jobs.length > 1
      jobs = for job in @state.jobs
        JobView {job, key: job}
    else
      jobs = []

    loaderStatus = if @state.status is 'fetching' then 'active' else ''

    div className: "secondary #{ @getColour() } row",
      div className: 'ten wide column',
        h2 {},
          Icon status: @state.status
          @props.repo
      div className: 'right aligned six wide column',
        div className: 'ui large grey tag label',
          @state.branch,
          '#',
          @state.commit.hash.slice(0, 5),
        p {},
          @state.commit.author,
          ': '
          @state.commit.message
      div className: 'sixteen wide column',
        div className: 'ui huge labels',
          jobs
      div className: "ui #{ loaderStatus } dimmer",
        div className: 'ui loader'

Icon = React.createFactory React.createClass

  render: -> i className: "#{ ICONS[@props.status] } icon"

Loader = React.createFactory React.createClass

  render: ->
    div className: 'ui active dimmer',
      div className: 'ui loader'

GHStats = React.createFactory React.createClass

  componentDidMount: ->
    node = @refs.prog1.getDOMNode()
    $(node).progress percent: 22
    node_2 = @refs.prog2.getDOMNode()
    $(node_2).progress percent: 75

  render: -> div className: 'ui segment',
    div className: 'ui grid',
      div className: 'row',
        div className: 'eight wide column',
          div className: 'grid',
            div className: 'row',
              div className: 'eight wide column',
                div className: 'ui progress', ref: 'prog1',
                  div className: 'bar',
                    div className: 'progress'
                  div className: 'label',
                    'milestone 1'
              div className: 'eight wide column',
                div className: 'ui progress', ref: 'prog2',
                  div className: 'bar',
                    div className: 'progress'
                  div className: 'label',
                    'milestone 1'
        div className: 'eight wide column ui statistics',
          div className: 'statistic',
            div className: 'value',
              '125'
            div className: 'label',
              'open issues'
          div className: 'statistic',
            div className: 'value',
              '16'
            div className: 'label',
              'pull requests'
          div className: 'statistic',
            div className: 'value',
              '54'
            div className: 'label',
              'releases'

BuildsView = React.createFactory React.createClass

  componentDidMount: ->
    node = @refs.prog1.getDOMNode()
    $(node).progress percent: 22

  render: ->
    builds = ((BuildView {repo: repo, key: repo}) for repo in @props.repos)

    div {},
      GHStats()
      div className: 'ui vertically padded grid',
        builds

React.render (BuildsView {repos}), document.querySelector('#app')
