React = require 'react'

Icon = React.createFactory require './icon'

{div} = React.DOM

STATS = [
  {key: 'issues', icon: 'bug', label: 'open issues'},
  {key: 'pulls', icon: 'fork', label: 'pull requests'},
  {key: 'releases', icon: 'tag', label: 'releases'},
  {key: 'forks', icon: 'github', label: 'forks'},
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
