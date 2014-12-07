{Router} = require 'express'

logger = require 'winston'

module.exports = (base, db) ->
  router = Router()
  reposets = db.collection('reposets')
  fileOptions =
    root: base + '/dist'
    dotfiles: 'deny'

  router.get '/new', (req, res) ->
    if req.accepts('html')
      res.sendFile 'new.html', fileOptions, (err) ->
        if err
          logger.error err
          res.status(err.status).end()
    else
       res.sendStatus(406)

  router.post '/:board', (req, res) ->
    reposets.findOne {board: req.params.board}, (err, board) ->
      if err?
        logger.error err
        res.sendStatus 500
      else if board?
        res.status(400).send('Already exists')
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

