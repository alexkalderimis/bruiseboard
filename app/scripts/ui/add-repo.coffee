React = require 'react/addons'

{div, h3, input, button} = React.DOM
Icon = React.createFactory require './icon'

btnClass = ({repo}) -> React.addons.classSet
  'huge circular ui primary icon button': true
  'disabled': (!repo || !(/\w+\/\w+/.test repo))

module.exports = AddRepo = React.createClass

  getInitialState: -> {}

  setRepo: -> @setState repo: @refs.repo.getDOMNode().value

  render: ->
    div className: 'ui center aligned page grid',
      div className: 'one column row',
        div className: 'sixteen wide column',
          h3 className: 'ui header',
            'Add repository'
      div className: 'two column divided row',
        div className: 'eight wide column',
          div className: 'ui huge transparent left icon input',
            input
              type: 'text'
              ref: 'repo'
              onChange: @setRepo
              value: @state.repo
              placeholder: 'repository'
            Icon icon: 'github'
        div className: 'eight wide column',
          button className: (btnClass @state),
            Icon icon: 'plus'
