type params = {
  directory?: bool,
  multiple?: bool,
}

module type T = {
  type response
}

module Make = (T: T) => {
  @module("@tauri-apps/plugin-dialog")
  external open_: params => promise<T.response> = "open"
}
