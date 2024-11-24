use std::{ffi::OsStr, path::Path};

#[derive(Debug)]
pub enum ImageFormat {
  Png,
  Jpeg,
}

impl ImageFormat {
  pub fn from_ext<S>(ext: S) -> Option<ImageFormat>
  where
    S: AsRef<OsStr>,
  {
    fn inner(ext: &OsStr) -> Option<ImageFormat> {
      let ext = ext.to_str()?.to_ascii_lowercase();
      Some(match ext.as_str() {
        "jpg" | "jpeg" => ImageFormat::Jpeg,
        "png" => ImageFormat::Png,
        _ => return None,
      })
    }
    inner(ext.as_ref())
  }

  pub fn from_ext_str<P>(ext: P) -> Option<ImageFormat>
  where
    P: AsRef<Path>,
  {
    fn inner(ext: &Path) -> Option<ImageFormat> {
      ext.extension().and_then(ImageFormat::from_ext)
    }
    inner(ext.as_ref())
  }
}
