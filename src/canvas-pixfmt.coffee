umd = (factory) ->
  if typeof define is 'function' and define.amd
    define [], factory
  else if typeof exports is 'object'
    module.exports = factory()
  else
    @CanvasPixfmt = factory()

umd ->
  {CanvasPixfmtBase, CanvasPixfmtRGBA, CanvasPixfmtYUV}
