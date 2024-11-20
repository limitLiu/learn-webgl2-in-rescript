let vsGLSL = `#version 300 es
  in vec2 a_position;
  uniform vec2 u_resolution;

  void main() {
    vec2 zeroToOne = a_position / u_resolution;
    vec2 zeroToTwo = zeroToOne * 2.0;
    vec2 clipSpace = zeroToTwo - 1.0;
    gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);
  }
`

let fsGLSL = `#version 300 es
  precision highp float;
  uniform vec4 u_color;
  out vec4 outColor;
  void main() {
    outColor = u_color;
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

let draw = (canvas: Dom.element) => {
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

      let uResolution = gl->WebGL.getUniformLocation(program, "u_resolution")
      let uColor = gl->WebGL.getUniformLocation(program, "u_color")

      let vertexBuffer = gl->createBuffer
      let vao = gl->WebGL.createVertexArray
      gl->WebGL.bindVertexArray(vao)
      gl->enableVertexAttribArray(aPosition)
      gl->bindBuffer(_ARRAY_BUFFER, vertexBuffer)

      let size = 2
      let kind = _FLOAT
      let normalize = false
      let stride = 0
      let offset = 0
      gl->vertexAttribPointer(aPosition, size, kind, normalize, stride, offset)
      let width = gl->WebGL.canvas->WebGL.width
      let height = gl->WebGL.canvas->WebGL.height
      gl->WebGL.viewport(0., 0., width, height)
      gl->clearColor(0.75, 0.85, 0.8, 1.0)
      gl->clear(lor(_COLOR_BUFFER_BIT, _DEPTH_BUFFER_BIT))
      gl->useProgram(program)
      gl->WebGL.bindVertexArray(vao)
      gl->WebGL.uniform2f(uResolution, width, height)
      Array.make(~length=50, 0)->Array.forEach(_ => {
        gl->rectangle(
          randomInRange(300.),
          randomInRange(300.),
          randomInRange(300.),
          randomInRange(300.),
        )
        gl->WebGL.uniform4f(uColor, Math.random(), Math.random(), Math.random(), 1.)
        let primitiveType = _TRIANGLES
        let offset = 0
        let count = 6
        gl->drawArrays(primitiveType, offset, count)
      })
    })
    ->ignore
  | _ => ()
  }
}
