%%raw("import '@/assets/scss/App.scss'")

module T = {
  type params = {s: string}
  type response = string
}

include Native.Make(T)

let main = async () => {
  open Webapi
  switch document->Dom.Document.querySelector("#root") {
  | Some(canvas) => GlobalShortcut.register("CommandOrControl+O", async e => {
      if e.state == #Released {
        let file_path = await Open.open_({multiple: false, directory: false})
        let read = await invoke("read", {s: file_path})
        let image = document->Dom.Document.createElement("img")
        if read->String.length > 0 {
          image->Dom.Element.setAttribute("src", read)
          image->Texture.Image.onload(_ => {
            canvas->Renderer.draw(image)
          })
        }
      }
    })->Promise.done
  | None => ()
  }
}

main()->Promise.done
