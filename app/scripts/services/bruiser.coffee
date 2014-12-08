request = require 'browser-request'

exports.get_repos = (cb) ->
  req =
    method: 'GET'
    uri: String(document.location)
    json: true
    
  request req, (err, resp, data) ->
    resp.status ?= resp.statusCode
    console.log resp.status, resp.statusCode
    if resp.status >= 400
      return cb resp
    else if err
      console.error err, resp.status, data
      return cb err
    return cb null, data

exports.add_repo = (repo, done) ->
  req =
    method: 'POST'
    uri: "#{ document.location }/repos"
    json: [repo]

  request req, (err, resp) ->
    resp.status ?= resp.statusCode if resp.statusCode?
    if err or resp.status >= 400
      console.error err, resp.status
      return done resp
    return done()



