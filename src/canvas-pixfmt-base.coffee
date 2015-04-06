class CanvasPixfmtBase
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
    void main (void) {
      gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
    }
  '''

  constructor: (@canvas, @size) ->
    @gl = @canvas.getContext 'webgl'
    @gl.viewportWidth = @canvas.width
    @gl.viewportHeight = @canvas.height

    @program = @_createProgram @gl, @vs_source, @fs_source
    @attrib = @_createAttrib @gl
    @texture = @_createTexture @gl
    @_useProgram @gl, @program, @attrib, @texture

  _createProgram: (gl, vs_src='', fs_src='') ->
    vs = gl.createShader gl.VERTEX_SHADER
    gl.shaderSource vs, vs_src
    gl.compileShader vs
    if !gl.getShaderParameter vs, gl.COMPILE_STATUS
      alert gl.getShaderInfoLog vs
      return null

    fs = gl.createShader gl.FRAGMENT_SHADER
    gl.shaderSource fs, fs_src
    gl.compileShader fs
    if !gl.getShaderParameter fs, gl.COMPILE_STATUS
      alert gl.getShaderInfoLog fs
      return null

    program = gl.createProgram()
    gl.attachShader program, vs
    gl.attachShader program, fs
    gl.linkProgram program
    if !gl.getProgramParameter program, gl.LINK_STATUS
      alert 'Could not initialise shaders'
      return null

    program

  _createAttrib: (gl) ->
    vpa = new Float32Array [-1, -1, 1, -1, 1, 1, -1, 1]
    vpb = gl.createBuffer()
    vpb.itemSize = 2
    vpb.numItems = 4
    gl.bindBuffer gl.ARRAY_BUFFER, vpb
    gl.bufferData gl.ARRAY_BUFFER, vpa, gl.STATIC_DRAW

    tca = new Float32Array [0, 0, 1, 0, 1, 1, 0, 1]
    tcb = gl.createBuffer()
    tcb.itemSize = 2
    tcb.numItems = 4
    gl.bindBuffer gl.ARRAY_BUFFER, tcb
    gl.bufferData gl.ARRAY_BUFFER, tca, gl.STATIC_DRAW

    via = new Uint16Array [0, 1, 2, 0, 2, 3]
    vib = gl.createBuffer()
    vib.itemSize = 1
    vib.numItems = 6
    gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, vib
    gl.bufferData gl.ELEMENT_ARRAY_BUFFER, via, gl.STATIC_DRAW

    {vpb, tcb, vib}

  _createTexture: (gl) ->
    texture = []

  _useProgram: (gl, program, attrib, texture) ->
    gl.useProgram program
    attrib.vpb.location = gl.getAttribLocation program, 'aVertexPosition'
    attrib.tcb.location = gl.getAttribLocation program, 'aTextureCoord'
    gl.enableVertexAttribArray attrib.vpb.location
    gl.enableVertexAttribArray attrib.tcb.location

  setup: ->
    @gl.clearColor 0.0, 0.0, 0.0, 1.0

    @gl.viewport 0, 0, @gl.viewportWidth, @gl.viewportHeight
    @gl.clear @gl.COLOR_BUFFER_BIT

    @gl.bindBuffer @gl.ARRAY_BUFFER, @attrib.vpb
    @gl.vertexAttribPointer @attrib.vpb.location, @attrib.vpb.itemSize, @gl.FLOAT, false, 0, 0
    @gl.bindBuffer @gl.ARRAY_BUFFER, @attrib.tcb
    @gl.vertexAttribPointer @attrib.tcb.location, @attrib.tcb.itemSize, @gl.FLOAT, false, 0, 0

    TEXTURE = [@gl.TEXTURE0, @gl.TEXTURE1, @gl.TEXTURE2, @gl.TEXTURE3]
    for i in [0...@texture.length]
      @gl.activeTexture TEXTURE[i]
      @gl.bindTexture @gl.TEXTURE_2D, @texture[i]
      @gl.uniform1i @texture[i].location, i

  fill: ->

  draw: ->
    @gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, @attrib.vib
    @gl.drawElements @gl.TRIANGLES, @attrib.vib.numItems, @gl.UNSIGNED_SHORT, 0
