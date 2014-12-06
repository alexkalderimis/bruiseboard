React = require 'react'
{div} = React.DOM

module.exports = Loader = React.createClass

  render: ->
    div className: 'ui active dimmer',
      div className: 'ui loader'

