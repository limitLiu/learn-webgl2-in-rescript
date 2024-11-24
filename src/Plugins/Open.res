type params = {
  directory?: bool,
  multiple?: bool,
}

@module("@tauri-apps/plugin-dialog")
external open_: params => promise<string> = "open"
