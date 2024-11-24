#![allow(dead_code)]
pub mod encoder {
  const TABLE: &str = "\
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  trait CharAt {
    fn char_at(&self, index: usize) -> char;
  }

  impl CharAt for str {
    fn char_at(&self, index: usize) -> char {
      self[index..].chars().next().unwrap()
    }
  }

  pub fn encode(bytes: &[u8], size: usize) -> String {
    let mut buffer = Vec::<char>::new();
    buffer.resize((size + 2) / 3 * 4, '=');
    let mut i = 0;
    let mut j = 0;
    let n = size / 3 * 3;
    while i < n {
      let x: u32 = ((bytes[i] as u32) << 16) | ((bytes[i + 1] as u32) << 8) | (bytes[i + 2] as u32);
      buffer[j] = TABLE.char_at(((x >> 18) & 63) as usize);
      buffer[j + 1] = TABLE.char_at(((x >> 12) & 63) as usize);
      buffer[j + 2] = TABLE.char_at(((x >> 6) & 63) as usize);
      buffer[j + 3] = TABLE.char_at((x & 63) as usize);
      i += 3;
      j += 4;
    }
    if i + 1 == size {
      let x = (bytes[i] as u32) << 16;
      buffer[j] = TABLE.char_at(((x >> 18) & 63) as usize);
      buffer[j + 1] = TABLE.char_at(((x >> 12) & 63) as usize);
    } else if i + 2 == size {
      let x = (bytes[i] as u32) << 16 | (bytes[i + 1] as u32) << 8;
      buffer[j] = TABLE.char_at(((x >> 18) & 63) as usize);
      buffer[j + 1] = TABLE.char_at(((x >> 12) & 63) as usize);
      buffer[j + 2] = TABLE.char_at(((x >> 6) & 63) as usize);
    }
    buffer.iter().collect()
  }
}

pub mod decoder {
  use thiserror::Error;

  const INVALID_BASE64_BYTE: u8 = 64;

  #[derive(Debug, Error)]
  pub enum Base64Error {
    #[error("Invalid Base64 character {0:#2x} at index {1}")]
    InvalidCharacter(u8, usize),
    #[error("Base64 encoded strings must be a multiple of 4 bytes in length")]
    InvalidLength,
  }

  fn decode_byte(byte: u8) -> u8 {
    const INV: u8 = INVALID_BASE64_BYTE;
    #[rustfmt::skip]
    const DECODE_TABLE: [u8; 256] = [
      INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, // ........
      INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, // ........
      INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, 62,  INV, INV, INV, 63,  // ...+.../
      52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  INV, INV, INV, 0,   INV, INV, // 89...=..
      INV, 0,   1,   2,   3,   4,   5,   6,   7,   8,   9,   10,  11,  12,  13,  14,  // .ABCDEFG
      15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  INV, INV, INV, INV, INV, // XYZ.....
      INV, 26,  27,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,  // .abcdefg
      41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  INV, INV, INV, INV, INV, // hijklmno
      INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, // pqrstuvw
      INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, // xyz.....
      INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, // ........
      INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, // ........
      INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, // ........
      INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, // ........
      INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, // ........
      INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, INV, // ........
    ];

    DECODE_TABLE[byte as usize]
  }

  pub fn decode(input: &str) -> Result<Vec<u8>, Base64Error> {
    let input_bytes = input.as_bytes();
    let input_length = input_bytes.len();

    if input_length % 4 != 0 {
      return Err(Base64Error::InvalidLength);
    }

    let first_valid_equal_idx = input_length.saturating_sub(2);
    let mut output = Vec::with_capacity((input_length / 4) * 3);

    let mut hex64_bytes = [0u8; 4];
    for (idx, chunk) in input_bytes.chunks_exact(4).enumerate() {
      for (i, &byte) in chunk.iter().enumerate() {
        let decoded_byte = decode_byte(byte);
        if decoded_byte == INVALID_BASE64_BYTE {
          if byte == b'=' {
            if idx * 4 + i < first_valid_equal_idx
              || (idx * 4 + i == first_valid_equal_idx && input_bytes[idx * 4 + i + 1] != b'=')
            {
              return Err(Base64Error::InvalidCharacter(byte, idx * 4 + i));
            }
          } else {
            return Err(Base64Error::InvalidCharacter(byte, idx * 4 + i));
          }
        }
        hex64_bytes[i] = decoded_byte;
      }

      output.push((hex64_bytes[0] << 2) | (hex64_bytes[1] >> 4));
      output.push((hex64_bytes[1] << 4) | (hex64_bytes[2] >> 2));
      output.push((hex64_bytes[2] << 6) | hex64_bytes[3]);
    }

    if input_bytes[input_length - 1] == b'=' {
      output.pop();
      if input_bytes[input_length - 2] == b'=' {
        output.pop();
      }
    }

    Ok(output)
  }
}

#[test]
fn test_encode() {
  use encoder::encode;
  assert_eq!(encode("".as_bytes(), 0), "");
  assert_eq!(encode("f".as_bytes(), 1), "Zg==");
  assert_eq!(encode("fo".as_bytes(), 2), "Zm8=");
  assert_eq!(encode("foo".as_bytes(), 3), "Zm9v");
  assert_eq!(encode("foob".as_bytes(), 4), "Zm9vYg==");
}

#[test]
fn test_decode() {
  use decoder::decode;
  assert_eq!(decode("Zg==").unwrap(), vec![102]);
  assert_eq!(decode("Zm8=").unwrap(), vec![102, 111]);
  assert_eq!(decode("Zm9v").unwrap(), vec![102, 111, 111]);
  assert_eq!(decode("Zm9vYg==").unwrap(), vec![102, 111, 111, 98]);
}
