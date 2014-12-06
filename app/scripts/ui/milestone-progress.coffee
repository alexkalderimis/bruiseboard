React = require 'react'

{div} = React.DOM

{very_frequently} = require './times'

module.exports = MilestoneProgress = React.createClass
  
  displayName: 'MilestoneProgress'

  getDefaultProps: -> milestones: [
    {name: 'release 1.4', tickets: 143, completed: 74},
    {name: 'release 1.5', tickets: 34, completed: 28},
    {name: 'future release', tickets: 12, completed: 3},
  ]

  # Assumes $ is available, which it will be since
  # bower will have loaded it in.
  componentDidMount: ->
    n = 0
    node = $ @refs.prog.getDOMNode()

    setProgress = =>
      index = (n++ % @props.milestones.length)
      milestone = @props.milestones[index]
      total = milestone.tickets
      value = milestone.completed
      active = "Closed {value} of {total} tickets in #{ milestone.name }"
      success = "All {total} tickets in milestone #{ milestone.name } closed"

      node.progress {total, value, text: {active, success}}

    @interval = setInterval setProgress, very_frequently
    setProgress()

  componentWillUnmount: -> clearInterval @interval

  render: ->
    div className: 'ui indicating progress', ref: 'prog',
      div className: 'bar',
        div className: 'progress'
      div className: 'label',
        'milestone'
