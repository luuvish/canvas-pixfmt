class CanvasPixfmtYUV extends CanvasPixfmtBase
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
    uniform sampler2D uTextureY;
    uniform sampler2D uTextureU;
    uniform sampler2D uTextureV;
    const mat4 YUV2RGB = mat4(
      1.1643828125, 0            , 1.59602734375, -.87078515625,
      1.1643828125, -.39176171875, -.81296875   , .52959375    ,
      1.1643828125, 2.017234375  , 0            , -1.081390625 ,
      0           , 0            , 0            , 1
    );
    void main (void) {
      gl_FragColor = vec4(
        texture2D(uTextureY, vTextureCoord).x,
        texture2D(uTextureU, vTextureCoord).x,
        texture2D(uTextureV, vTextureCoord).x,
        1
      ) * YUV2RGB;
    }
  '''

  _createTexture: (gl) ->
    texture = (gl.createTexture() for i in [0...3])
    for tex in texture
      gl.bindTexture gl.TEXTURE_2D, tex
      gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, true
      gl.texImage2D gl.TEXTURE_2D, 0, gl.LUMINANCE, 0, 0, 0, gl.LUMINANCE, gl.UNSIGNED_BYTE, null
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE
      gl.bindTexture gl.TEXTURE_2D, null
    texture

  _useProgram: (gl, program, attrib, texture) ->
    super
    texture[0].location = gl.getUniformLocation program, 'uTextureY'
    texture[1].location = gl.getUniformLocation program, 'uTextureU'
    texture[2].location = gl.getUniformLocation program, 'uTextureV'

  fill: (buffer) ->
    for i in [0...@texture.length]
      width = buffer[i].width
      height = buffer[i].height
      @gl.bindTexture @gl.TEXTURE_2D, @texture[i]
      @gl.texImage2D @gl.TEXTURE_2D, 0, @gl.LUMINANCE, width, height, 0, @gl.LUMINANCE, @gl.UNSIGNED_BYTE, buffer[i]
