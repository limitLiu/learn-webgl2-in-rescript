module type T = {
  type params
  type response
}

module Make = (T: T) => {
  @module("@tauri-apps/api/core")
  external invoke: (string, T.params) => promise<T.response> = "invoke"

  @module("@tauri-apps/api/core")
  external invokeWithoutParams: string => promise<T.response> = "invoke"
}
