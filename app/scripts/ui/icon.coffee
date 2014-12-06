React = require 'react'

{i} = React.DOM

ICONS =
  error: 'bug'
  queued: 'wait'
  started: 'setting loading'
  passed: 'checkmark'
  failed: 'remove'

module.exports = Icon = React.createClass

  displayName: 'Icon'

  render: ->
    cls = @props.icon or ICONS[@props.status]
    i className: "#{ cls } icon"

