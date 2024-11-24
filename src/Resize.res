let resizeCanvas = (canvas: Dom.element, ~multiplier=1.) => {
  let multiplier = Math.max(0., multiplier)
  let width = canvas->WebGL.clientWidth *. multiplier
  let height = canvas->WebGL.clientHeight *. multiplier
  if canvas->WebGL.width != width || canvas->WebGL.height != height {
    canvas->Webapi.Canvas.CanvasElement.setWidth(width->Float.toInt)
    canvas->Webapi.Canvas.CanvasElement.setHeight(height->Float.toInt)
  }
}
