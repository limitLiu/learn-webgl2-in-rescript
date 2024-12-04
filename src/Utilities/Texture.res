module Image = {
  type t = Dom.element
  type event = {@as("type") type_: string}
  @set external onload: (t, event => unit) => unit = "onload"
  @set external onerror: (t, event => unit) => unit = "onerror"

  @new external make: unit => t = "Image"
}

let make = (gl: WebGL.t) => {
  let texture = gl->WebGL.createTexture
  gl->WebGL.bindTexture(WebGL._TEXTURE_2D, texture)

  gl->WebGL.texParameteri(WebGL._TEXTURE_2D, WebGL._TEXTURE_WRAP_S, WebGL._CLAMP_TO_EDGE)
  gl->WebGL.texParameteri(WebGL._TEXTURE_2D, WebGL._TEXTURE_WRAP_T, WebGL._CLAMP_TO_EDGE)
  gl->WebGL.texParameteri(WebGL._TEXTURE_2D, WebGL._TEXTURE_MIN_FILTER, WebGL._NEAREST)
  gl->WebGL.texParameteri(WebGL._TEXTURE_2D, WebGL._TEXTURE_MAG_FILTER, WebGL._NEAREST)
  texture
}
