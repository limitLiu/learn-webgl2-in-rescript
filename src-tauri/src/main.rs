// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod base64;
mod format;

use std::fs::File;
use std::io::{self, Read};

use format::ImageFormat;

fn parse(path: &str) -> io::Result<Box<dyn Read>> {
  let file = File::open(path)?;
  Ok(Box::new(file))
}

#[tauri::command]
fn read(s: String) -> Result<String, String> {
  let mut buf = Vec::new();
  let size = parse(&s)
    .map_err(|e| e.to_string())?
    .read_to_end(&mut buf)
    .map_err(|e| e.to_string())?;

  let fmt = ImageFormat::from_ext_str(s).map(|fmt| match fmt {
    ImageFormat::Png => "data:image/png;base64,",
    ImageFormat::Jpeg => "data:image/jpg;base64,",
  });
  Ok(match fmt {
    Some(f) => format!("{}{}", f, base64::encoder::encode(&buf, size)),
    None => "".to_string(),
  })
}

fn main() {
  tauri::Builder::default()
    .plugin(tauri_plugin_dialog::init())
    .plugin(tauri_plugin_clipboard_manager::init())
    .plugin(tauri_plugin_os::init())
    .plugin(tauri_plugin_notification::init())
    .plugin(tauri_plugin_process::init())
    .plugin(tauri_plugin_fs::init())
    .plugin(tauri_plugin_shell::init())
    .plugin(tauri_plugin_global_shortcut::Builder::new().build())
    .plugin(tauri_plugin_http::init())
    .invoke_handler(tauri::generate_handler![read])
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}
