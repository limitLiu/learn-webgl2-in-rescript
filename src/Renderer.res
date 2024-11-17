let vsGLSL = `#version 300 es
  in vec4 a_position;
  void main() {
    gl_Position = a_position;
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
      let vertexBuffer = gl->createBuffer
      gl->bindBuffer(_ARRAY_BUFFER, vertexBuffer)
      let indices = [0., 0., 0., 0.5, 0.7, 0.]
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
      gl->WebGL.viewport(0., 0., gl->WebGL.canvas->WebGL.width, gl->WebGL.canvas->WebGL.height)
      gl->clearColor(0.75, 0.85, 0.8, 1.0)
      gl->clear(_COLOR_BUFFER_BIT)
      gl->useProgram(program)
      gl->WebGL.bindVertexArray(vao)

      let primitiveType = _TRIANGLES
      let offset = 0
      let count = 3
      gl->drawArrays(primitiveType, offset, count)
    })
    ->ignore
  | _ => ()
  }
}
