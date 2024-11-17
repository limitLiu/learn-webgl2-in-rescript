%%raw("import '@/assets/scss/App.scss'")

let resize = (canvas: Dom.element, _: Dom.event) => {
  open Webapi
  open Canvas.CanvasElement

  canvas->setWidth(Window.innerWidth * Window.devicePixelRatio)
  canvas->setHeight(Window.innerHeight * Window.devicePixelRatio)
  canvas->Renderer.draw
}

let main = () => {
  open Webapi
  switch document->Dom.Document.querySelector("#root") {
  | Some(canvas) => {
      open Canvas.CanvasElement
      Dom.window->Dom.Window.addEventListener("resize", e => resize(canvas, e))
      canvas->setWidth(Window.innerWidth * Window.devicePixelRatio)
      canvas->setHeight(Window.innerHeight * Window.devicePixelRatio)
      canvas->Renderer.draw
    }
  | None => ()
  }
}

main()
