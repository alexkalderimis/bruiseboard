React = require 'react'
_ = require 'lodash'

{div} = React.DOM

{very_frequently} = require './times'

PROGRESS_OPTIONS =
  showActivity: false
  performance: false
  verbose: false
  debug: false
  label: 'ratio'

module.exports = MilestoneProgress = React.createClass
  
  displayName: 'MilestoneProgress'

  getInitialState: -> index: 0

  getDefaultProps: -> milestones: []

  # Assumes $ is available, which it will be since
  # bower will have loaded it in.
  componentDidMount: ->
    @interval = setInterval @nextMilestone, very_frequently
    $(@refs.progress.getDOMNode()).progress PROGRESS_OPTIONS

  componentDidUpdate: ->
    @updateProgress()

  updateProgress: ->
    milestone = (@props.milestones[@state.index] ? {})
    {tickets, closed_issues} = milestone
    options = _.assign {}, PROGRESS_OPTIONS, value: closed_issues, total: tickets
    node = $ @refs.progress.getDOMNode()
    node.progress options

  nextMilestone: ->
    return unless @props.milestones.length
    index = (++@state.index % @props.milestones.length)
    @setState index: index

  componentWillUnmount: ->
    clearInterval @interval

  render: ->
    milestone = (@props.milestones[@state.index] ? {})
    {title, tickets, closed_issues} = milestone
    div className: 'ui indicating progress', 'data-value': closed_issues, 'data-total': tickets, ref: 'progress',
      div className: 'bar',
        div className: 'progress'
      div className: 'label',
        title
