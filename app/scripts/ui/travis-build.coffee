React = require 'react'

{frequently, less_frequently} = require './times'
Colors = require './colors'

Job = React.createFactory require './job-view'
Icon = React.createFactory require './icon'

{div, h2, p} = React.DOM

DONE = ['failed', 'passed', 'errored']

module.exports = TravisBuild = React.createClass

  displayName: 'TravisBuild'

  getDefaultProps: ->
    jobs: []
    status: 'fetching'
    commit:
      author: 'unknown'
      message: 'none'
      hash: ''
    
  update: -> @props.requestBuildUpdate @props.repo

  componentDidMount: ->
    @interval = setInterval @update, frequently

  componentWillReceiveProps: ({status}) ->
    if status in DONE
      clearInterval @interval
      @interval = setInterval @update, less_frequently

  componentWillUnmount: -> clearInterval @interval

  getColour: -> Colors[@props.status]

  loader: ->
    cls = if @props.status is 'fetching' then 'active' else ''
    div className: "ui #{ cls } dimmer",
      div className: 'ui loader'

  jobs: ->
    if @props.jobs.length > 1
      for job in @props.jobs
        job.key = job.id
        job.requestUpdate = @props.requestJobUpdate.bind null, @props.repo
        Job job
    else
      []

  render: ->
    div className: "secondary #{ @getColour() } row",
      div className: 'ten wide column',
        h2 {},
          Icon status: @props.status
          @props.repo
      div className: 'right aligned six wide column',
        div className: 'ui large grey tag label',
          @props.branch,
          '#',
          @props.commit.hash.slice(0, 5),
        p {},
          @props.commit.author,
          ': '
          @props.commit.message
      div className: 'sixteen wide column',
        div className: 'ui huge labels',
          @jobs()
      @loader()
