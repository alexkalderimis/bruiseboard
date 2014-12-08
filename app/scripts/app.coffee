React   = require 'react'
_       = require 'lodash'
{EventEmitter2} = require 'eventemitter2'

travis = require './services/travis'
github = require './services/github'
bruiser = require './services/bruiser'

App = React.createFactory require './ui/dashboard'
AddRepo = React.createFactory require './ui/add-repo'
Apology = React.createFactory require './ui/apology'

bus = new EventEmitter2

node = document.querySelector('#app')
topbar = document.querySelector '#topbar'
$(topbar).sidebar onHide: -> bus.emit 'topbar.hide'

bruiser.get_repos (err, data) ->
  if err
    return React.render (Apology _.pick err, 'status', 'message'), node

  showTopBar = -> $(topbar).sidebar 'toggle'
  shouldReset = bus.on.bind bus, 'topbar.hide'
  props = _.assign data, travis, github, addRepo: showTopBar
  addRepo = (repo) ->
    console.log 'adding', repo
    props.repos.push repo
    $(topbar).sidebar 'hide'
    React.unmountComponentAtNode node
    React.render (App props), node
    bruiser.add_repo repo, (err) -> console.error(err) if err?

  adderProps = {shouldReset, addRepo, get_repo: github.get_repo}
  React.render (AddRepo adderProps), topbar
  React.render (App props), node
