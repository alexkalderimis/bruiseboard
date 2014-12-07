React = require 'react'

{div} = React.DOM

MilestoneProgress = React.createFactory require './milestone-progress'
RepoStats = React.createFactory require './repo-stats'

module.exports = GHStats = React.createClass

  render: -> div className: 'ui segment',
    div className: 'ui grid',
      div className: 'row',
        div className: 'eight wide column',
          MilestoneProgress @props
        div className: 'eight wide column',
          RepoStats @props

