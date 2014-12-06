request = require 'browser-request'

api_base = 'https://api.travis-ci.org'
headers = {Accept: 'application/vnd.travis-ci.2+json'}

exports.get_build = (repo, cb) ->
  options =
    method: 'GET'
    uri: api_base + '/builds'
    headers: headers
    qs: {slug: repo}
  request options, (err, resp, body) ->
    return cb err if err?
    return cb new Error("Request failed: #{ resp.status }") unless resp.status is 200
    try
      {builds, commits} = JSON.parse body
    catch e
      return cb e
    latest = builds[0]
    commit = c for c in commits when c.id is latest.commit_id
    build =
      repo: repo
      status: latest.state
      number: latest.number
      jobs: ({id} for id in latest.job_ids)
      branch: commit.branch
      commit:
        author: commit.author_name
        message: commit.message
        hash: commit.sha
    cb null, build

exports.get_job = (id, cb) ->
  if typeof id isnt 'number'
    return cb new Error('id must be a number')
  options =
    method: 'GET'
    uri: "#{ api_base }/jobs/#{ id }"
    headers: headers
  request options, (err, resp, body) ->
    return cb err if err?
    return cb new Error("Request failed: #{ resp.status }") unless resp.status is 200
    try
      {job, commit} = JSON.parse body
    catch e
      return cb e

    # console.debug job
    nameParts = []

    if job.config?.python?
      nameParts.push job.config.python
    if job.config?.jdk?
      nameParts.push job.config.jdk
    if job.config?.env?
      nameParts.push job.config.env.replace /\S+=/g, ''

    name = nameParts.join ' '
    status = job.state
    cb null, {name, status}

