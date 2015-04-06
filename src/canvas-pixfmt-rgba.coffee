class CanvasPixfmtRGBA extends CanvasPixfmtBase
  vs_source: '''
    attribute vec3 aVertexPosition;
    attribute vec2 aTextureCoord;
    varying vec2 vTextureCoord;
    void main (void) {
      gl_Position = vec4(aVertexPosition, 1.0);
      vTextureCoord = aTextureCoord;
    }
  '''
  fs_source: '''
    precision highp float;
    varying vec2 vTextureCoord;
    uniform sampler2D uTextureRGB;
    void main (void) {
      gl_FragColor = texture2D(uTextureRGB, vTextureCoord);
    }
  '''

  _createTexture: (gl) ->
    texture = [gl.createTexture()]
    gl.bindTexture gl.TEXTURE_2D, texture[0]
    gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, true
    gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, 0, 0, 0, gl.RGBA, gl.UNSIGNED_BYTE, null
    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST
    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST
    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE
    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE
    gl.bindTexture gl.TEXTURE_2D, null
    texture

  _useProgram: (gl, program, attrib, texture) ->
    super
    texture[0].location = gl.getUniformLocation program, 'uTextureRGB'

  fill: (buffer) ->
    width = buffer.width
    height = buffer.height
    @gl.bindTexture @gl.TEXTURE_2D, @texture[0]
    @gl.texImage2D @gl.TEXTURE_2D, 0, @gl.RGBA, width, height, 0, @gl.RGBA, @gl.UNSIGNED_BYTE, buffer
