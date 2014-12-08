{Router} = require 'express'

logger = require 'winston'

module.exports = (base, db) ->
  router = Router()
  reposets = db.collection('reposets')
  fileOptions =
    root: base + '/dist'
    dotfiles: 'deny'

  router.post '/:board/repos', (req, res) ->
    if not req.body or not req.body.length
      return res.sendStatus 400

    reposets.findOne {board: req.params.board}, (err, board) ->
      if err?
        logger.error err
        return res.sendStatus 500
      if not board?
        return res.sendStatus 404

      repos = board.repos.concat req.body
      reposets.update {board: req.params.board}, {$set: {repos}}, (err) ->
        if err?
          logger.error err
          return res.sendStatus 500
        res.json repos

  router.post '/:board', (req, res) ->
    reposets.findOne {board: req.params.board}, (err, board) ->
      if err?
        logger.error err
        return res.sendStatus 500
      else if board?
        return res.status(400).send('Already exists')

      reposets.insert {board: req.params.board, repos: []}, (err, board) ->
        if err?
          logger.error err
          res.sendStatus 500
        res.sendFile 'index.html', fileOptions, (err) ->
          if err
            logger.error err
            res.status(err.status).end()

  router.get '/:board', (req, res) ->
    if req.accepts('html')

      res.sendFile 'index.html', fileOptions, (err) ->
        if err
          logger.error err
          res.status(err.status).end()

    else if req.accepts('application/json')
      reposets.findOne {board: req.params.board}, (err, board) ->
        if err?
          logger.error err
          res.sendStatus 500
        else if not board?
          res.sendStatus 404
        else
          res.json(board)
    else
       res.sendStatus(406)

  return router

