request = require 'browser-request'

exports.get_repos = (cb) ->
  req =
    method: 'GET'
    uri: String(document.location)
    json: true
    
  request req, (err, resp, data) ->
    if err or resp.status >= 400
      console.error err, resp.status, body
      return cb resp
    return cb null, data

exports.add_repo = (repo, done) ->
  req =
    method: 'POST'
    uri: "#{ document.location }/repos"
    json: [repo]

  request req, (err, resp) ->
    if err or resp.status >= 400
      console.error err, resp.status
      return done resp
    return done()



