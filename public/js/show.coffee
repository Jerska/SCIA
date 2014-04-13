hljs.initHighlightingOnLoad()

showHide = (id) ->
  console.log 'In showHide'
  elt = document.getElementById(id).style
  if elt.height != '1px'
    elt.height = '1px'
    elt.visibility = 'hidden'
  else
    elt.height = ''
    elt.visibility = 'visible'

document.getElementById('toc-heading').addEventListener("click", -> showHide('toc-ul'))
