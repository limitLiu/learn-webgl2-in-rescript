%%raw("import '@/assets/scss/App.scss'")

switch ReactDOM.querySelector("#root") {
| Some(rootElement) =>
  ReactDOM.Client.createRoot(rootElement)->ReactDOM.Client.Root.render(
    <React.StrictMode>
      <App />
    </React.StrictMode>,
  )
| None => ()
}
