module Image = {
  type t = Dom.element
  type event = {@as("type") type_: string}
  @set external onload: (t, event => unit) => unit = "onload"
}
