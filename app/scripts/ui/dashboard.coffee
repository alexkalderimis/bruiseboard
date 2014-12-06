React = require 'react'
_ = require 'lodash'

{div} = React.DOM

GHStats = React.createFactory require './gh-stats'
Build = React.createFactory require './travis-build'

module.exports = Dashboard = React.createClass

  displayName: 'Dashboard'

  getInitialState: -> builds: {}

  componentWillMount: ->
    repos = @props.repos
    builds = _.zipObject repos, ({repo, key: repo, jobs: []} for repo in repos)
    @setState builds: builds

    for repo in @props.repos
      @updateRepo repo

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
    for b in _.sortBy (_.values @state.builds), 'startedAt'
      _.assign b, {requestBuildUpdate: rbu, requestJobUpdate: rju}

  render: ->
    div {},
      GHStats()
      div className: 'ui vertically padded grid',
        ((Build b) for b in @builds())

