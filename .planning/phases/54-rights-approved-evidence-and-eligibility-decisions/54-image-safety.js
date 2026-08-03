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
    try {
      const headerSlice = file.slice(0, Math.min(file.size, MAX_HEADER_BYTES));
      const headerBytes = await headerSlice.arrayBuffer();
      const header = parseImageHeader(headerBytes, file.type, limits);
      if (!header.valid) return { valid: false, header: false };
      const sha256 = await sha256Hex(file, environment);

      const ImageCtor = environment.ImageCtor || globalObject.Image;
      const createObjectURL = environment.createObjectURL || globalObject.URL.createObjectURL.bind(globalObject.URL);
      const revokeObjectURL = environment.revokeObjectURL || globalObject.URL.revokeObjectURL.bind(globalObject.URL);
      return await new Promise((resolve) => {
        let temporaryURL = null;
        let finished = false;
        const finish = (value) => {
          if (finished) return;
          finished = true;
          if (temporaryURL !== null) {
            try { revokeObjectURL(temporaryURL); } catch (_) { /* fixed failure below */ }
          }
          resolve(value);
        };
        try {
          temporaryURL = createObjectURL(file);
          const image = new ImageCtor();
          image.addEventListener("load", () => finish({
            valid: image.naturalWidth === header.naturalWidth
              && image.naturalHeight === header.naturalHeight,
            naturalWidth: header.naturalWidth,
            naturalHeight: header.naturalHeight,
            sha256,
          }), { once: true });
          image.addEventListener("error", () => finish({ valid: false, decode: false }), { once: true });
          image.src = temporaryURL;
        } catch (_) {
          finish({ valid: false, read: false });
        }
      });
    } catch (_) {
      return { valid: false, read: false };
    }
  }

  function installDisplayObjectURLs(files, images, environment = {}) {
    const temporaryURLs = [];
    let revokeObjectURL = null;
    const clearSources = () => {
      if (!Array.isArray(images)) return;
      for (const image of images) {
        try { image.removeAttribute("src"); } catch (_) { /* keep clearing siblings */ }
      }
    };

    try {
      if (!Array.isArray(files) || files.length !== 3
        || !Array.isArray(images) || images.length !== 3) throw new Error("invalid_display_triple");
      const createObjectURL = environment.createObjectURL
        || globalObject.URL.createObjectURL.bind(globalObject.URL);
      revokeObjectURL = environment.revokeObjectURL
        || globalObject.URL.revokeObjectURL.bind(globalObject.URL);
      for (const file of files) {
        const url = createObjectURL(file);
        if (typeof url !== "string" || url.length === 0) throw new Error("invalid_object_url");
        temporaryURLs.push(url);
      }
      images.forEach((image, index) => { image.src = temporaryURLs[index]; });
      return Object.freeze({ valid: true, urls: Object.freeze([...temporaryURLs]) });
    } catch (_) {
      if (revokeObjectURL !== null) {
        for (const url of temporaryURLs) {
          try { revokeObjectURL(url); } catch (_) { /* attempt every owned URL */ }
        }
      }
      clearSources();
      return Object.freeze({ valid: false, urls: Object.freeze([]) });
    }
  }

  const api = Object.freeze({ parseImageHeader, inspectAndDecode, installDisplayObjectURLs });
  globalObject.ImageSafety = api;
  if (typeof module !== "undefined" && module.exports) module.exports = api;
})(typeof globalThis !== "undefined" ? globalThis : this);
