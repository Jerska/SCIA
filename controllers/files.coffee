_ = require 'lodash'
fs = require 'fs'
async = require 'async'
marked = require 'marked'
renderer = new marked.Renderer()
toc = []

exTableRenderer = renderer.table
tableRenderer = (i, j) ->
  exTableRenderer(i, j).replace('<table>', '<table class="table table-striped table-bordered">')
renderer.table = tableRenderer

renderer.heading = (text, level, raw) ->
  toc.push {name: text, anchor: "#{toc.length}", level: level} if level <= 3
  "<h#{level} id=\"#{this.options.headerPrefix}#{toc.length - 1}\">#{text}</h#{level}>\n"

marked.setOptions gfm: true, tables: true, breaks: true, smartLists: true, smartypants: true, renderer: renderer

parseToc = ->
  res = {name: "", anchor: "", level: 0, next: {}}
  chain = []
  i = 0
  for elt, i in toc
    while elt.level <= (if (a = chain.slice(-1)[0])? then toc[a].level else 0)
      chain.pop()
    chain.push i
    curr = res
    for e in chain
      curr.next[e] ||= {next: {}}
      curr = curr.next[e]
    curr.name = elt.name
    curr.anchor = elt.anchor
  res


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
  toc = []
  fs.readFile name, (err, file) ->
    return cb err if err
    marked "#{file}", (err, content) ->
      return cb err if err
      cb null, {content: content, toc: parseToc()}
