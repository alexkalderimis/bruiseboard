React = require 'react'

Colors = require './colors'
{frequently, less_frequently} = require './times'

{a, span} = React.DOM

DONE = ['passed', 'failed', 'errored']

# props = {name :: string, status :: string}
JobView = React.createClass

  displayName: 'JobView'

  update: -> @props.requestUpdate @props.job.id

  componentDidMount: ->
    @interval = setInterval @update, frequently

  componentWillReceiveProps: ({status}) ->
    if status? and status in DONE
      clearInterval @interval
      @interval = setInterval @update, less_frequently

  componentWillUnmount: -> clearInterval @interval

  render: ->
    {name, status} = @props
    cls = "ui right floated #{ Colors[status] } label"

    if name? then (a {className: cls}, name) else span()

module.exports = JobView
