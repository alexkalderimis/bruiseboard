React = require 'react'
_ = require 'lodash'
request = require 'browser-request'

repos = require './json/repos.json'

travis = require './services/travis'
github = require './services/github'

App = React.createFactory require './ui/dashboard'
Apology = React.createFactory require './ui/apology'

req =
  method: 'GET'
  uri: String(document.location)
  headers:
    Accept: 'application/json'
  
request req, (err, resp, body) ->
  node = document.querySelector('#app')
  if err or resp.status >= 400
    console.error err, resp.status, body
    React.render (Apology status: resp.status), node
  else
    data = JSON.parse body
    props = _.assign data, travis, github
    React.render (App props), node
