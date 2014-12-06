React = require 'react'
_ = require 'lodash'

repos = require './json/repos.json'

travis = require './services/travis'

App = React.createFactory require './ui/dashboard'

props = _.assign {repos}, travis

React.render (App props), document.querySelector('#app')
