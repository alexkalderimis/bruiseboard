React = require 'react'
_ = require 'lodash'

repos = require './json/repos.json'

travis = require './services/travis'
github = require './services/github'

App = React.createFactory require './ui/dashboard'

props = _.assign {repos}, travis, github

React.render (App props), document.querySelector('#app')
