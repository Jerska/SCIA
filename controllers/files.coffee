_ = require 'lodash'
fs = require 'fs'
async = require 'async'
marked = require 'marked'

marked.setOptions gfm: true, tables: true, breaks: true, smartLists: true, smartypants: true

exports.getAllFiles = (directory, cb) ->
  files = []
  folders = []
  directories = {}
  fs.readdir directory, (err, all) ->
    return null if err
    async.each all, (item, next) ->
      path = "#{directory}/#{item}"
      fs.stat path, (err, stat) ->
        return next err if err
        if stat and stat.isDirectory()
          exports.getAllFiles path, (err, results) ->
            return next err if err
            folders.push item
            directories[item] = results
            next null
        else
          files.push item
          next null
    , (err) ->
      return cb err if err
      cb null, {files: files.sort(), folders: folders.sort(), directories: directories}

exports.readMarkdownFile = (name, cb) ->
  fs.readFile name, (err, file) ->
    return cb err if err
    marked "#{file}", (err, content) ->
      return cb err if err
      cb null, content


