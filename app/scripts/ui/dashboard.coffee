React = require 'react'
_ = require 'lodash'

{div, button} = React.DOM

{infrequently} = require './times'

GHStats = React.createFactory require './gh-stats'
Build = React.createFactory require './travis-build'
Icon = React.createFactory require './icon'

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

    # Can make up to 60 requests per hour per IP - we are making
    # four requests here, so maximum update frequency is 15 times per hour
    @interval = setInterval @updateStats, infrequently

  updateStats: ->
    [primaryRepo] = @props.repos
    return unless primaryRepo?
    @updateMilestones primaryRepo
    @updatePulls primaryRepo
    @updateRepoStats primaryRepo
    @updateReleases primaryRepo

  componentWillUnmount: ->
    clearInterval @interval

  updateMilestones: (repo) ->
    @props.get_milestones repo, (err, milestones) =>
      @setState milestones: (m for m in milestones when m.closed_issues)

  updatePulls: (repo) ->
    @props.get_pulls repo, (err, n) =>
      @setState pulls: n

  updateReleases: (repo) ->
    @props.get_releases repo, (err, n) =>
      @setState releases: n

  updateRepoStats: (repo) ->
    @props.get_repo repo, (err, stats) =>
      if err?
        console.error err
      console.log repo
      @setState issues: stats.open_issues, forks: stats.forks

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
      div className: 'ui segment',
        button className: 'huge circular ui secondary icon button',
          Icon icon: 'configure'
        button className: 'huge circular ui primary icon button',
          Icon icon: 'plus'
          

