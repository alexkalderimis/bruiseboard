React = require 'react'

Icon = React.createFactory require './icon'

{div} = React.DOM

STATS = [
  {key: 'issues', icon: 'bug', label: 'open issues'},
  {key: 'releases', icon: 'tag', label: 'releases'},
  {key: 'pulls', icon: 'vertically flipped fork', label: 'pull requests'},
  {key: 'forks', icon: 'fork', label: 'forks'},
]

module.exports = RepoStats = React.createClass
  
  displayName: 'RepoStats'

  getDefaultProps: ->
    issues: 125
    pulls: 16
    releases: 54
    forks: 22

  stat: ({key, icon, label}) ->
    div className: 'statistic', key: key,
      div className: 'value',
        Icon {icon}
        @props[key]
      div className: 'label',
        label

  render: ->
    div className: 'ui statistics',
      (@stat s for s in STATS)
