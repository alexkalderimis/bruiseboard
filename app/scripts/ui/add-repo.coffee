React = require 'react/addons'

{span, div, h3, input, button, form} = React.DOM
Icon = React.createFactory require './icon'

repo_like = (s) -> /\w+\/\w+/.test s

btnClass = ({repo, phase}) -> React.addons.classSet
  'huge circular ui primary icon button': true
  'loading': (phase is 'checking')
  'disabled': (not repo_like repo)

module.exports = AddRepo = React.createClass

  getInitialState: -> phase: 'waiting', repo: null

  setRepo: -> @setState repo: @refs.repo.getDOMNode().value

  componentDidMount: -> @props.shouldReset => @setState @getInitialState()

  checkRepo: ->
    @setState err: null, phase: 'checking'
    @props.get_repo @state.repo, (err, repo) =>
      if err?
        return @setState {phase: 'waiting', err}
      console.log repo
      @setState found: repo, phase: 'confirm'

  addRepo: -> @props.addRepo @state.repo

  render: ->
    btn = if @state.phase is 'confirm'
      div className: 'ui items',
        div className: 'item',
          div className: 'content',
            div className: 'header',
              @state.found.full_name
            div className: 'meta',
              span className: 'language', @state.found.language
            div className: 'description', @state.found.description
            div className: 'extra',
              button onClick: @addRepo, className: 'ui right floated primary button',
                'Add this repo'
    else
      button onClick: @checkRepo, className: (btnClass @state),
        Icon icon: 'plus'

    inputClasses = React.addons.classSet
      'ui huge transparent left icon input': true
      'error': !!@state.err

    errorIndicator = if @state.err?
      div className: 'ui pointing left red label',
        'bad repository name'
    else
      div()

    div className: 'ui center aligned page grid',
      div className: 'one column row',
        div className: 'sixteen wide column',
          h3 className: 'ui header',
            'Add repository'
      div className: 'two column divided row',
        div className: 'eight wide column',
          div className: 'field',
            div className: inputClasses,
              input
                type: 'text'
                ref: 'repo'
                disabled: (@state.phase in ['checking', 'confirm'])
                onChange: @setRepo
                value: @state.repo
                placeholder: 'repository'
              Icon icon: 'github'
            errorIndicator
        div className: 'eight wide column', btn
