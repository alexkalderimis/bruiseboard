React = require 'react'
_ = require 'lodash'

{div} = React.DOM

{infrequently} = require './times'

GHStats = React.createFactory require './gh-stats'
Build = React.createFactory require './travis-build'

module.exports = Dashboard = React.createClass

  displayName: 'Dashboard'

  getInitialState: -> builds: {}, milestones: []

  componentWillMount: ->
    repos = @props.repos
    builds = _.zipObject repos, ({repo, key: repo, jobs: []} for repo in repos)
    @setState builds: builds

    for repo in @props.repos
      @updateRepo repo

    @updateStats()
    @interval = setInterval @updateStats, infrequently

  updateStats: ->
    @updateMilestones()
    @updatePulls()
    @updateRepoStats()
    @updateReleases()

  componentWillUnmount: ->
    clearInterval @interval

  updateMilestones: ->
    [primaryRepo] = @props.repos
    @props.get_milestones primaryRepo, (err, milestones) =>
      @setState milestones: (m for m in milestones when m.closed_issues)

  updatePulls: ->
    [primaryRepo] = @props.repos
    @props.get_pulls primaryRepo, (err, n) =>
      @setState pulls: n

  updateReleases: ->
    [primaryRepo] = @props.repos
    @props.get_releases primaryRepo, (err, n) =>
      @setState releases: n

  updateRepoStats: ->
    [primaryRepo] = @props.repos
    @props.get_repo primaryRepo, (err, repo) =>
      if err?
        console.error err
      console.log repo
      @setState issues: repo.open_issues, forks: repo.forks

  updateRepo: (repo) ->
    @props.get_build repo, (err, build) =>
      if err?
        console.error "Error updating #{ repo }", err
        return
      _.assign @state.builds[repo], build
      @setState builds: @state.builds
      for job in build.jobs
        @updateJob repo, job.id

  updateJob: (repo, id) ->
    @props.get_job id, (err, job) =>
      if err?
        console.error "Error updating job #{ repo }:#{ id }", err
        return
      current = _.find @state.builds[repo].jobs, (j) -> j.id is id
      _.assign current, job
      @setState builds: @state.builds

  builds: ->
    rbu = @updateRepo
    rju = @updateJob
    for b in _(@state.builds).values().sortBy('startedAt').reverse().value()
      _.assign b, {requestBuildUpdate: rbu, requestJobUpdate: rju}

  render: ->
    div {},
      GHStats @state
      div className: 'ui vertically divided grid',
        ((Build b) for b in @builds())

