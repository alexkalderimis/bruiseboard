React = require 'react'

{div, h2} = React.DOM

BuildView = React.createFactory React.createClass

  render: ->
    div className: 'ui vertical segment',
      div className: 'ui page grid',
        div className: 'column',
          h2 {}, "Build #{ @props.num }"
          "dummy"

BuildsView = React.createFactory React.createClass

  getInitialState: -> builds: [0 .. 10]

  render: ->
    div className: 'ui grid', (BuildView(key: i, num: i + 1) for i in @state.builds)

builds = BuildsView()
React.render builds, document.querySelector('#app')


