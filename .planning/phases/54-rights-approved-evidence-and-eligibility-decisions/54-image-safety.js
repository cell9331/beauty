(function attachImageSafety(globalObject) {
  "use strict";

  const MAX_HEADER_BYTES = 65_536;
  const JPEG_START_OF_FRAME = new Set([
    0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6, 0xC7,
    0xC9, 0xCA, 0xCB, 0xCD, 0xCE, 0xCF,
  ]);

  function readUint32BE(bytes, offset) {
    return ((bytes[offset] * 0x1000000)
      + (bytes[offset + 1] << 16)
      + (bytes[offset + 2] << 8)
      + bytes[offset + 3]);
  }

  function pngDimensions(bytes) {
    const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    if (bytes.length < 24 || !signature.every((value, index) => bytes[index] === value)) return null;
    if (bytes[12] !== 0x49 || bytes[13] !== 0x48 || bytes[14] !== 0x44 || bytes[15] !== 0x52) return null;
    return { width: readUint32BE(bytes, 16), height: readUint32BE(bytes, 20), format: "png" };
  }

  function jpegDimensions(bytes) {
    if (bytes.length < 4 || bytes[0] !== 0xFF || bytes[1] !== 0xD8) return null;
    let offset = 2;
    while (offset < bytes.length) {
      while (offset < bytes.length && bytes[offset] === 0xFF) offset += 1;
      if (offset >= bytes.length) return null;
      const marker = bytes[offset];
      offset += 1;
      if (marker === 0xD8 || marker === 0x01 || (marker >= 0xD0 && marker <= 0xD7)) continue;
      if (marker === 0xD9 || marker === 0xDA || offset + 1 >= bytes.length) return null;
      const segmentLength = (bytes[offset] << 8) + bytes[offset + 1];
      if (segmentLength < 2 || offset + segmentLength > bytes.length) return null;
      if (JPEG_START_OF_FRAME.has(marker)) {
        if (segmentLength < 7) return null;
        return {
          width: (bytes[offset + 5] << 8) + bytes[offset + 6],
          height: (bytes[offset + 3] << 8) + bytes[offset + 4],
          format: "jpeg",
        };
      }
      offset += segmentLength;
    }
    return null;
  }

  function dimensionsWithinPolicy(dimensions, limits) {
    if (dimensions === null
      || !Number.isSafeInteger(dimensions.width)
      || !Number.isSafeInteger(dimensions.height)
      || dimensions.width < 1
      || dimensions.height < 1
      || dimensions.width > limits.maxDimension
      || dimensions.height > limits.maxDimension) return false;
    const pixelCount = dimensions.width * dimensions.height;
    return Number.isSafeInteger(pixelCount) && pixelCount <= limits.maxPixels;
  }

  function parseImageHeader(value, mimeType, limits) {
    const bytes = value instanceof Uint8Array ? value : new Uint8Array(value);
    const dimensions = mimeType === "image/png"
      ? pngDimensions(bytes)
      : mimeType === "image/jpeg" ? jpegDimensions(bytes) : null;
    if (!dimensionsWithinPolicy(dimensions, limits)) return Object.freeze({ valid: false });
    return Object.freeze({
      valid: true,
      naturalWidth: dimensions.width,
      naturalHeight: dimensions.height,
      format: dimensions.format,
    });
  }

  async function sha256Hex(file, environment) {
    const fullBytes = typeof file.arrayBuffer === "function"
      ? await file.arrayBuffer()
      : await file.slice(0, file.size).arrayBuffer();
    const subtle = environment.cryptoSubtle || globalObject.crypto.subtle;
    const digest = new Uint8Array(await subtle.digest("SHA-256", fullBytes));
    return Array.from(digest, (value) => value.toString(16).padStart(2, "0")).join("");
  }

  async function inspectAndDecode(file, limits, environment = {}) {
    const headerSlice = file.slice(0, Math.min(file.size, MAX_HEADER_BYTES));
    const headerBytes = await headerSlice.arrayBuffer();
    const header = parseImageHeader(headerBytes, file.type, limits);
    if (!header.valid) return { valid: false, header: false };
    const sha256 = await sha256Hex(file, environment);

    const ImageCtor = environment.ImageCtor || globalObject.Image;
    const createObjectURL = environment.createObjectURL || globalObject.URL.createObjectURL.bind(globalObject.URL);
    const revokeObjectURL = environment.revokeObjectURL || globalObject.URL.revokeObjectURL.bind(globalObject.URL);
    return new Promise((resolve) => {
      const temporaryURL = createObjectURL(file);
      const image = new ImageCtor();
      const finish = (value) => {
        revokeObjectURL(temporaryURL);
        resolve(value);
      };
      image.addEventListener("load", () => finish({
        valid: image.naturalWidth === header.naturalWidth
          && image.naturalHeight === header.naturalHeight,
        naturalWidth: header.naturalWidth,
        naturalHeight: header.naturalHeight,
        sha256,
      }), { once: true });
      image.addEventListener("error", () => finish({ valid: false, decode: false }), { once: true });
      image.src = temporaryURL;
    });
  }

  const api = Object.freeze({ parseImageHeader, inspectAndDecode });
  globalObject.ImageSafety = api;
  if (typeof module !== "undefined" && module.exports) module.exports = api;
})(typeof globalThis !== "undefined" ? globalThis : this);
