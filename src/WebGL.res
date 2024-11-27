open Webapi.Canvas.WebGl

type t = glT

type vertexArrayT

type textureT

type shader = Vertex(string) | Fragment(string)

let _COMPILE_STATUS = 35713
let _LINK_STATUS = 35714
let _TEXTURE0 = 33984
let _TEXTURE_2D = 3553

let _TEXTURE_MAG_FILTER = 10240
let _TEXTURE_MIN_FILTER = 10241
let _TEXTURE_WRAP_S = 10242
let _TEXTURE_WRAP_T = 10243

let _CLAMP_TO_EDGE = 33071
let _NEAREST = 9728

let _RGBA = 6408
let _UNSIGNED_BYTE = 5121

@send
external bufferFloatData: (t, int, Float32Array.t, int) => unit = "bufferData"

@send
external getContextWebGL2: (Dom.element, @as("webgl2") _) => t = "getContext"

@send
external getShaderParameter: (t, shaderT, int) => bool = "getShaderParameter"

@send
external getProgramParameter: (t, programT, int) => bool = "getProgramParameter"

@send
external deleteShader: (t, shaderT) => unit = "deleteShader"

@send
external deleteProgram: (t, programT) => unit = "deleteShader"

@send
external createVertexArray: t => vertexArrayT = "createVertexArray"

@send external createTexture: t => textureT = "createTexture"

@send external activeTexture: (t, int) => unit = "activeTexture"

@send external bindTexture: (t, int, textureT) => unit = "bindTexture"

@send external texParameteri: (t, int, int, int) => unit = "texParameteri"

@send
external texImage2D: (t, int, int, int, int, int, Dom.element) => unit = "texImage2D"

@send
external bindVertexArray: (t, vertexArrayT) => unit = "bindVertexArray"

@send
external viewport: (t, float, float, float, float) => unit = "viewport"

@get
external canvas: t => Dom.element = "canvas"

@get external width: Dom.element => float = "width"
@get external height: Dom.element => float = "height"

@get external clientWidth: Dom.element => float = "clientWidth"
@get external clientHeight: Dom.element => float = "clientHeight"

@send external getUniformLocation: (t, programT, string) => int = "getUniformLocation"

@send external uniform1f: (t, int, float) => unit = "uniform1f"
@send external uniform2f: (t, int, float, float) => unit = "uniform2f"
@send external uniform4f: (t, int, float, float, float, float) => unit = "uniform4f"
@send external uniform1i: (t, int, float) => unit = "uniform1i"
@send external uniform1fv: (t, int, array<float>) => unit = "uniform1fv"

let make = (canvas: Dom.element) => canvas->getContextWebGL2

let makeShader = (gl: t, kind: shader) => {
  let (s, source) = switch kind {
  | Vertex(source) => (gl->createShader(_VERTEX_SHADER), source)
  | Fragment(source) => (gl->createShader(_FRAGMENT_SHADER), source)
  }
  gl->shaderSource(s, source)
  gl->compileShader(s)
  let isSuccess = gl->getShaderParameter(s, _COMPILE_STATUS)
  if isSuccess {
    Some(s)
  } else {
    Console.log(gl->getShaderInfoLog(s))
    gl->deleteShader(s)
    None
  }
}

let makeProgram = (gl: t, vertextShader: shaderT, fragmentShader: shaderT) => {
  let program = gl->createProgram
  gl->attachShader(program, vertextShader)
  gl->attachShader(program, fragmentShader)
  gl->linkProgram(program)
  let isSuccess = gl->getProgramParameter(program, _LINK_STATUS)
  if isSuccess {
    Some(program)
  } else {
    Console.log(gl->getProgramInfoLog(program))
    gl->deleteProgram(program)
    None
  }
}
