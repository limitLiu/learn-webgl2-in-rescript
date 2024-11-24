type state = [#Pressed | #Released]

type registerEvent = {
  id: int,
  state: state,
  shortcut: string,
}
@module("@tauri-apps/plugin-global-shortcut")
external register: (string, registerEvent => promise<unit>) => promise<Nullable.t<unit>> =
  "register"
