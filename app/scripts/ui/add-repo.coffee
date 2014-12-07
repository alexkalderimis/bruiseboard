React = require 'react'

{div, h3, input, button} = React.DOM
Icon = React.createFactory require './icon'

module.exports = AddRepo = React.createClass

  getInitialState: -> {}

  render: ->
    div className: 'ui center aligned page grid',
      div className: 'one column row',
        div className: 'sixteen wide column',
          h3 className: 'ui header',
            'Add repository'
      div className: 'two column divided row',
        div className: 'eight wide column',
          div className: 'ui huge transparent left icon input',
            input type: 'text', value: @state.newRepo, placeholder: 'repository'
            Icon icon: 'github'
        div className: 'eight wide column',
          button className: 'huge circular ui primary icon button',
            Icon icon: 'plus'
