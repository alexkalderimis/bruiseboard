request = require 'browser-request'
_ = require 'lodash'

api_base = 'https://api.github.com'
headers = Accept: 'application/vnd.github.v3+json'

milestones_path = (repo) -> "/repos/#{ repo }/milestones"
pulls_path      = (repo) -> "/repos/#{ repo }/pulls"
repo_path       = (repo) -> "/repos/#{ repo }"
releases_path   = (repo) -> "/repos/#{ repo }/releases"

exports.get_milestones = (repo, cb) ->

  method = 'GET'
  uri = api_base + milestones_path repo

  request {method, uri, headers}, (err, {status}, body) ->
    return cb err if err?
    return cb new Error("Request failed: #{ status } - #{ body }") unless status is 200
    try
      milestones = JSON.parse body
    catch e
      return cb new Error("Could not parse response as json: #{ e } - #{ body }")
    open_milestones = for m in milestones when m.state is 'open'
      _.assign m, tickets: (m.open_issues + m.closed_issues)

    cb null, open_milestones

exports.get_pulls = (repo, cb) ->

  method = 'GET'
  uri = api_base + pulls_path repo

  request {method, uri, headers}, (err, {status}, body) ->
    return cb err if err?
    return cb new Error("Request failed: #{ status } - #{ body }") unless status is 200
    try
      pulls = JSON.parse body
    catch e
      return cb new Error("Could not parse response as json: #{ e } - #{ body }")

    open_pulls = (p for p in pulls when p.state is 'open')
    console.log (p.title for p in open_pulls)

    cb null, open_pulls.length

exports.get_repo = (repo, cb) ->

  method = 'GET'
  uri = api_base + repo_path repo

  request {method, uri, headers}, (err, {status}, body) ->
    return cb err if err?
    return cb new Error("Request failed: #{ status } - #{ body }") unless status is 200
    try
      data = JSON.parse body
    catch e
      return cb new Error("Could not parse response as json: #{ e } - #{ body }")

    cb null, data

exports.get_releases = (repo, cb) ->

  method = 'GET'
  uri = api_base + releases_path repo

  request {method, uri, headers}, (err, {status}, body) ->
    return cb err if err?
    return cb new Error("Request failed: #{ status } - #{ body }") unless status is 200
    try
      data = JSON.parse body
    catch e
      return cb new Error("Could not parse response as json: #{ e } - #{ body }")

    cb null, data.length
