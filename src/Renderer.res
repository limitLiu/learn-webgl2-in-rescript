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
  out vec4 outColor;
  void main() {
    outColor = vec4(1, 0, 0.5, 1);
  }
`

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
      let vertexBuffer = gl->createBuffer
      gl->bindBuffer(_ARRAY_BUFFER, vertexBuffer)
      let indices = [10., 20., 80., 20., 10., 30., 10., 30., 80., 20., 80., 30.]
      gl->WebGL.bufferFloatData(_ARRAY_BUFFER, indices->Float32Array.fromArray, _STATIC_DRAW)
      let vao = gl->WebGL.createVertexArray
      gl->WebGL.bindVertexArray(vao)
      gl->enableVertexAttribArray(aPosition)
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

      let primitiveType = _TRIANGLES
      let offset = 0
      let count = 6
      gl->drawArrays(primitiveType, offset, count)
    })
    ->ignore
  | _ => ()
  }
}
