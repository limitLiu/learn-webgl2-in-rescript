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

  uniform sampler2D u_image0;
  uniform sampler2D u_image1;

  in vec2 v_texCoord;
  out vec4 outColor;

  void main() {
    vec4 color0 = texture(u_image0, v_texCoord);
    vec4 color1 = texture(u_image1, v_texCoord);
    outColor = color0 * color1;
  }
`

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

let draw = (canvas: Dom.element, images: array<Dom.element>) => {
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
      let uImage0 = gl->WebGL.getUniformLocation(program, "u_image0")
      let uImage1 = gl->WebGL.getUniformLocation(program, "u_image1")

      let vao = gl->WebGL.createVertexArray
      gl->WebGL.bindVertexArray(vao)

      let vertexBuffer = gl->createBuffer
      gl->bindBuffer(_ARRAY_BUFFER, vertexBuffer)
      gl->enableVertexAttribArray(aPosition)

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

      let textures = images->Array.map(image => {
        let texture = gl->Texture.make
        let mipLevel = 0
        let internalFormat = WebGL._RGBA
        let srcFormat = WebGL._RGBA
        let srcType = _UNSIGNED_BYTE
        gl->WebGL.texImage2D(WebGL._TEXTURE_2D, mipLevel, internalFormat, srcFormat, srcType, image)
        texture
      })
      gl->bindBuffer(_ARRAY_BUFFER, vertexBuffer)
      switch images[0] {
      | Some(img) => gl->rectangle(0., 0., img->WebGL.width, img->WebGL.height)
      | _ => ()
      }

      canvas->Webapi.Canvas.CanvasElement.setWidth(Window.innerWidth * Window.devicePixelRatio)
      canvas->Webapi.Canvas.CanvasElement.setHeight(Window.innerHeight * Window.devicePixelRatio)
      let width = gl->WebGL.canvas->WebGL.width
      let height = gl->WebGL.canvas->WebGL.height
      gl->WebGL.viewport(0., 0., width, height)
      gl->clearColor(0.75, 0.85, 0.8, 1.0)
      gl->clear(lor(_COLOR_BUFFER_BIT, _DEPTH_BUFFER_BIT))
      gl->useProgram(program)
      gl->WebGL.bindVertexArray(vao)
      gl->WebGL.uniform2f(uResolution, width, height)
      gl->WebGL.uniform1i(uImage0, 0)
      gl->WebGL.uniform1i(uImage1, 1)

      textures
      ->Belt.Array.zip([WebGL._TEXTURE0, WebGL._TEXTURE1])
      ->Array.forEach(v => {
        let (tex, texture) = v
        gl->WebGL.activeTexture(texture)
        gl->WebGL.bindTexture(WebGL._TEXTURE_2D, tex)
      })

      let primitiveType = _TRIANGLES
      let offset = 0
      let count = 6
      gl->drawArrays(primitiveType, offset, count)
    })
    ->ignore
  | _ => ()
  }
}
