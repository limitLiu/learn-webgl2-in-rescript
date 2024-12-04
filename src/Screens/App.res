@module external main: {..} = "@/assets/scss/Main.module.scss"

module T = {
  type params = {s: string}
  type response = string
}

module Opens = {
  module OpenT = {
    type response = array<string>
  }
  include Open.Make(OpenT)
}

module Open = {
  module OpenT = {
    type response = string
  }
  include Open.Make(OpenT)
}

include Native.Make(T)

@react.component
let make = () => {
  let loadImage = React.useCallback0(url =>
    Promise.make((resolve, reject) => {
      open Webapi
      let image = Texture.Image.make()
      image->Texture.Image.onload(
        _ => {
          resolve(image)
        },
      )
      image->Texture.Image.onerror(reject)
      image->Dom.Element.setAttribute("src", url)
    })
  )

  let ref = React.useRef(null)
  <>
    <canvas id="canvas" ref={ReactDOM.Ref.domRef(ref)}>
      {"Your browser doesn't support canvas"->React.string}
    </canvas>
    <div className={main["btnGroup"]}>
      <button
        className={main["btn"]}
        onClick={_ => {
          Opens.open_({multiple: true, directory: false})
          ->Promise.thenResolve(async file_paths => {
            let images =
              (
                await Promise.all(
                  file_paths->Array.map(async s => {
                    let read = await invoke("read", {s: s})
                    if read->String.length > 0 {
                      Some(await loadImage(read))
                    } else {
                      None
                    }
                  }),
                )
              )
              ->Array.filter(img => img->Option.isSome)
              ->Array.map(img => img->Option.getExn)

            switch ref.current {
            | Value(canvas) => canvas->Renderer.draw(images)
            | _ => ()
            }
          })
          ->Promise.done
        }}>
        {"Load Images"->React.string}
      </button>
    </div>
  </>
}
