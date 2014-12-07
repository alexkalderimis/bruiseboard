React = require 'react'

{a, div, p, form, button} = React.DOM

module.exports = Apology = React.createClass

  displayName: 'Apology'

  render: ->
    title = if @props.status is 404 then 'Board not found' else 'Error'
    message = if @props.status isnt 404
      p {}, 'Could not load board'
    else
      div {},
        p {},
          'This board does not exist. Do you want to create it?'
        form method: 'POST',
          button type: 'submit', className: 'ui primary button',
            'Create board'

    div className: 'ui error message',
      div className: 'header',
        title
      message
