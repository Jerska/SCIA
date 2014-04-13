files = require '../controllers/files'
CLASSES_FOLDER = './cours/'

exports.index = (req, res) ->
  files.getAllFiles CLASSES_FOLDER, (err, files) ->
    return console.log err if err
    res.render 'index', files: files

exports.show = (req, res) ->
  filename = req.params[0]
  files.readMarkdownFile CLASSES_FOLDER + filename, (err, content) ->
    return console.log err if err
    res.render 'show', file: {name: filename, content: content.content, toc: content.toc}

exports.partials = (req, res) ->
  res.render "partials/#{req.params.name}"
