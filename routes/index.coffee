files = require '../controllers/files'
CLASSES_FOLDER = './cours/'

exports.index = (req, res) ->
  files.getAllFiles CLASSES_FOLDER, (err, files) ->
    return console.log err if err
    res.render 'index', files: files

exports.show = (req, res) ->
  filename = req.params[0]
  ext = require('path').extname filename
  if ext == '.txt' || ext == '.md' || ext == '.markdown'
    files.readMarkdownFile CLASSES_FOLDER + filename, (err, content) ->
      return console.log err if err
      res.render 'show', file: {name: filename, content: content.content, toc: content.toc}
  else
    res.sendfile CLASSES_FOLDER + filename

exports.partials = (req, res) ->
  res.render "partials/#{req.params.name}"
