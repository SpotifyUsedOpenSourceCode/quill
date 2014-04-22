_   = require('lodash')
DOM = require('./dom')


class Format
  @types:
    LINE: 'line'

  @EMBED_TEXT: '!' # No reason we picked ! besides it being one character (so delta cannot split it up)

  @FORMATS:
    bold:
      tag: 'B'
      preformat: 'bold'

    italic:
      tag: 'I'
      preformat: 'italic'

    underline:
      tag: 'U'
      preformat: 'underline'

    strike:
      tag: 'S'
      preformat: 'strikeThrough'

    color:
      style: 'color'
      default: '#000'
      preformat: 'foreColor'

    background:
      style: 'backgroundColor'
      default: '#fff'
      preformat: 'backColor'

    font:
      style: 'fontFamily'
      default: "'Helvetica', 'Arial', sans-serif"
      preformat: 'fontName'

    size:
      style: 'fontSize'
      default: '13px'
      preformat: 'fontSize'

    link:
      tag: 'A'
      attribute: 'href'

    image:
      tag: 'IMG'
      attribute: 'src'

    align:
      type: Format.types.LINE
      style: 'textAlign'
      default: 'left'


  constructor: (@config) ->

  add: (node, value) ->
    return this.remove(node) unless value
    return node if this.value(node) == value
    if _.isString(@config.tag)
      formatNode = node.ownerDocument.createElement(@config.tag)
      if DOM.VOID_TAGS[formatNode.tagName]?
        node.parentNode.insertBefore(formatNode, node) if node.parentNode?
        DOM.removeNode(node)
        node = formatNode
      else
        node = DOM.wrap(formatNode, node)
    if _.isString(@config.style)
      node.style[@config.style] = value if value != @config.default
    if _.isString(@config.attribute)
      node.setAttribute(@config.attribute, value)
    return node

  isType: (type) ->
    return type == @config.type

  match: (node) ->
    return false unless DOM.isElement(node)
    return false if _.isString(@config.tag) and node.tagName != @config.tag
    return false if _.isString(@config.style) and (!node.style[@config.style] or node.style[@config.style] == @config.default)
    return false if _.isString(@config.attribute) and !node.hasAttribute(@config.attribute)
    return true

  remove: (node) ->
    return unless this.match(node)
    if _.isString(@config.style)
      node.style[@config.style] = ''    # IE10 requires setting to '', other browsers can take null
      node.removeAttribute('style') unless node.getAttribute('style')  # Some browsers leave empty style attribute
    if _.isString(@config.attribute)
      node.removeAttribute(@config.attribute)
    if _.isString(@config.tag)
      node = DOM.switchTag(node, DOM.DEFAULT_INLNE_TAG)
      DOM.setText(node, Format.EMBED_TEXT) if DOM.EMBED_TAGS[@config.tag]?
    return node

  value: (node) ->
    return undefined unless this.match(node)
    return node.getAttribute(@config.attribute) or undefined if _.isString(@config.attribute)
    return node.style[@config.style] or undefined if _.isString(@config.style) and node.style[@config.style] != @config.default
    return true if _.isString(@config.tag) and node.tagName == @config.tag
    # TODO class regex
    return undefined


module.exports = Format
