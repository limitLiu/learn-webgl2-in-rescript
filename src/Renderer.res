let vsGLSL = `#version 300 es
  in vec2 a_position;
  in vec2 a_texCoord;

  uniform vec2 u_resolution;
  out vec2 v_texCoord;

  void main() {
    vec2 zeroToOne = a_position / u_resolution;
    vec2 zeroToTwo = zeroToOne * 2.0;
    vec2 clipSpace = zeroToTwo - 1.0;
    gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);
    v_texCoord = a_texCoord;
  }
`

let fsGLSL = `#version 300 es
  precision highp float;

  uniform sampler2D u_image;

  uniform float u_kernel[9];
  uniform float u_kernel_weight;

  in vec2 v_texCoord;
  out vec4 outColor;

  void main() {
    vec2 aPixel = vec2(1) / vec2(textureSize(u_image, 0));
    vec4 colorSum =
      texture(u_image, v_texCoord + aPixel * vec2(-1, -1)) * u_kernel[0] +
      texture(u_image, v_texCoord + aPixel * vec2( 0, -1)) * u_kernel[1] +
      texture(u_image, v_texCoord + aPixel * vec2( 1, -1)) * u_kernel[2] +
      texture(u_image, v_texCoord + aPixel * vec2(-1,  0)) * u_kernel[3] +
      texture(u_image, v_texCoord + aPixel * vec2( 0,  0)) * u_kernel[4] +
      texture(u_image, v_texCoord + aPixel * vec2( 1,  0)) * u_kernel[5] +
      texture(u_image, v_texCoord + aPixel * vec2(-1,  1)) * u_kernel[6] +
      texture(u_image, v_texCoord + aPixel * vec2( 0,  1)) * u_kernel[7] +
      texture(u_image, v_texCoord + aPixel * vec2( 1,  1)) * u_kernel[8];
    outColor = vec4((colorSum / u_kernel_weight).rgb, 1);
  }
`

let randomInRange = range => {
  Math.floor(Math.random() *. range)
}

let rectangle = (gl: WebGL.t, x, y, width, height) => {
  open Webapi.Canvas.WebGl
  let x1 = x
  let x2 = x +. width
  let y1 = y
  let y2 = y +. height
  gl->WebGL.bufferFloatData(
    _ARRAY_BUFFER,
    [x1, y1, x2, y1, x1, y2, x1, y2, x2, y1, x2, y2]->Float32Array.fromArray,
    _STATIC_DRAW,
  )
}

let draw = (canvas: Dom.element, image: Dom.element) => {
  open Webapi.Canvas.WebGl
  let gl = canvas->WebGL.make
  let vs = gl->WebGL.makeShader(Vertex(vsGLSL))
  let fs = gl->WebGL.makeShader(Fragment(fsGLSL))
  switch (vs, fs) {
  | (Some(v), Some(f)) =>
    gl
    ->WebGL.makeProgram(v, f)
    ->Option.map(program => {
      let aPosition = gl->getAttribLocation(program, "a_position")
      let aTexCoord = gl->getAttribLocation(program, "a_texCoord")

      let uResolution = gl->WebGL.getUniformLocation(program, "u_resolution")
      let uImage = gl->WebGL.getUniformLocation(program, "u_image")
      let uKernel = gl->WebGL.getUniformLocation(program, "u_kernel")
      let uKernelWeight = gl->WebGL.getUniformLocation(program, "u_kernel_weight")

      let vao = gl->WebGL.createVertexArray
      gl->WebGL.bindVertexArray(vao)

      let vertexBuffer = gl->createBuffer
      gl->enableVertexAttribArray(aPosition)
      gl->bindBuffer(_ARRAY_BUFFER, vertexBuffer)

      let size = 2
      let kind = _FLOAT
      let normalize = false
      let stride = 0
      let offset = 0
      gl->vertexAttribPointer(aPosition, size, kind, normalize, stride, offset)

      let texCoordBuffer = gl->createBuffer
      gl->bindBuffer(_ARRAY_BUFFER, texCoordBuffer)
      gl->WebGL.bufferFloatData(
        _ARRAY_BUFFER,
        [0., 0., 1.0, 0., 0., 1., 0., 1., 1., 0., 1., 1.]->Float32Array.fromArray,
        _STATIC_DRAW,
      )
      gl->enableVertexAttribArray(aTexCoord)

      let size = 2
      let kind = _FLOAT
      let normalize = false
      let stride = 0
      let offset = 0
      gl->vertexAttribPointer(aTexCoord, size, kind, normalize, stride, offset)

      let texture = gl->WebGL.createTexture
      gl->WebGL.activeTexture(WebGL._TEXTURE0)
      gl->WebGL.bindTexture(WebGL._TEXTURE_2D, texture)

      gl->WebGL.texParameteri(WebGL._TEXTURE_2D, WebGL._TEXTURE_WRAP_S, WebGL._CLAMP_TO_EDGE)
      gl->WebGL.texParameteri(WebGL._TEXTURE_2D, WebGL._TEXTURE_WRAP_T, WebGL._CLAMP_TO_EDGE)
      gl->WebGL.texParameteri(WebGL._TEXTURE_2D, WebGL._TEXTURE_MIN_FILTER, WebGL._NEAREST)
      gl->WebGL.texParameteri(WebGL._TEXTURE_2D, WebGL._TEXTURE_MAG_FILTER, WebGL._NEAREST)

      let mipLevel = 0
      let internalFormat = WebGL._RGBA
      let srcFormat = WebGL._RGBA
      let srcType = WebGL._UNSIGNED_BYTE
      gl->WebGL.texImage2D(WebGL._TEXTURE_2D, mipLevel, internalFormat, srcFormat, srcType, image)

      canvas->Webapi.Canvas.CanvasElement.setWidth(Window.innerWidth * Window.devicePixelRatio)
      canvas->Webapi.Canvas.CanvasElement.setHeight(Window.innerHeight * Window.devicePixelRatio)
      let width = gl->WebGL.canvas->WebGL.width
      let height = gl->WebGL.canvas->WebGL.height
      gl->bindBuffer(_ARRAY_BUFFER, vertexBuffer)
      gl->rectangle(0., 0., image->WebGL.width, image->WebGL.height)

      gl->WebGL.viewport(0., 0., width, height)
      gl->clearColor(0.75, 0.85, 0.8, 1.0)
      gl->clear(lor(_COLOR_BUFFER_BIT, _DEPTH_BUFFER_BIT))
      gl->useProgram(program)
      gl->WebGL.bindVertexArray(vao)
      gl->WebGL.uniform2f(uResolution, width, height)
      gl->WebGL.uniform1i(uImage, 0.)

      let unsharpen = [-1., -1., -1., -1., 9., -1., -1., -1., -1.]
      gl->WebGL.uniform1fv(uKernel, unsharpen)
      let weight = unsharpen->Array.reduce(0., (a, b) => a +. b)
      gl->WebGL.uniform1f(uKernelWeight, weight <= 0. ? 1. : weight)

      let primitiveType = _TRIANGLES
      let offset = 0
      let count = 6
      gl->drawArrays(primitiveType, offset, count)
    })
    ->ignore
  | _ => ()
  }
}
