React   = require 'react'
_       = require 'lodash'
request = require 'browser-request'
{EventEmitter2} = require 'eventemitter2'

repos = require './json/repos.json'

travis = require './services/travis'
github = require './services/github'

App = React.createFactory require './ui/dashboard'
AddRepo = React.createFactory require './ui/add-repo'
Apology = React.createFactory require './ui/apology'

bus = new EventEmitter2

req =
  method: 'GET'
  uri: String(document.location)
  headers:
    Accept: 'application/json'
  
request req, (err, resp, body) ->
  node = document.querySelector('#app')
  topbar = document.querySelector '#topbar'
  showTopBar = -> $(topbar).sidebar 'toggle'
  shouldReset = bus.on.bind bus, 'topbar.hide'
  if err or resp.status >= 400
    console.error err, resp.status, body
    React.render (Apology status: resp.status), node
  else
    data = JSON.parse body
    props = _.assign data, travis, github, addRepo: showTopBar
    addRepo = (repo) ->
      console.log 'adding', repo
      props.repos.push repo
      $(topbar).sidebar 'hide'
      React.unmountComponentAtNode node
      React.render (App props), node

    adderProps = get_repo: github.get_repo, shouldReset: shouldReset, addRepo: addRepo
    React.render (AddRepo adderProps), topbar
    React.render (App props), node
    $(topbar).sidebar onHide: -> bus.emit 'topbar.hide'
