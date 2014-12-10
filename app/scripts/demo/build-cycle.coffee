{randInt, randElem} = require './rand-tools'
gibberish = require '../json/commit-messages.json'

chars = '0123456789abcdef'
one_week = (7 * 24 * 60 * 60 * 1000)
now = (new Date).getTime()
one_week_ago = now - one_week

getCommitMessage = ->
  verb = randElem gibberish.verbs
  noun = randElem gibberish.objects
  "#{ verb } #{ noun }"

exports.initBuilds = (builds) ->
  for b in builds
    b.number = randInt 0, 100
    b.commit.message = getCommitMessage()
    b.startedAt = new Date(randInt one_week_ago, now)
    b.requestBuildUpdate = ->
    b.requestJobUpdate = ->

getHash = ->
  idxs = (randInt 0, 15 for i in [0 .. 7])
  (chars[i] for i in idxs)

resetBuild = (b) ->
  b.number++
  b.status = 'queued'
  not_before = b.startedAt.getTime()
  b.startedAt = new Date(randInt not_before, now)
  b.commit.hash = getHash()
  b.commit.message = getCommitMessage()
  for j in b.jobs
    j.status = 'queued'

advanceJob = (j) ->
  if j.status is 'queued'
    if Math.random() > 0.7
      j.status = 'started'
  else if j.status is 'started'
    r = Math.random()
    if r < 0.5
      j.status = 'started'
    else if r < 0.53
      j.status = 'errored'
    else if r < 0.6
      j.status = 'failed'
    else
      j.status = 'passed'

exports.advanceBuild = (b) ->
  if b.status is 'queued'
    if Math.random() > 0.5
      b.status = 'started'
  
  if b.status is 'started'
    for job in b.jobs
      advanceJob job

    if not (b.jobs.some (j) -> j.status in ['queued', 'started']) # All are done
      if (b.jobs.some (j) -> j.status is 'errored')
        b.status = 'errored'
      else if (b.jobs.some (j) -> j.status is 'failed')
        b.status = 'failed'
      else
        b.status = 'passed'
      setTimeout resetBuild.bind(null, b), randInt 5000, 10000
