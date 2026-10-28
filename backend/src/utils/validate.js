/**
 * Helper validasi & error HTTP kecil, dipakai semua controller.
 */

export class HttpError extends Error {
  constructor(status, message) {
    super(message)
    this.status = status
    this.expose = true
  }
}

export function parsePositiveInt(value, fieldName) {
  const num = Number(value)
  if (!Number.isInteger(num) || num <= 0) {
    throw new HttpError(400, `${fieldName} harus berupa bilangan bulat positif`)
  }
  return num
}

/**
 * Validasi koordinat WGS84: lat -90..90, lng -180..180.
 */
export function validateLatLng(lat, lng) {
  const latNum = Number(lat)
  const lngNum = Number(lng)
  if (!Number.isFinite(latNum) || latNum < -90 || latNum > 90) {
    throw new HttpError(400, 'lat harus berada di antara -90 dan 90')
  }
  if (!Number.isFinite(lngNum) || lngNum < -180 || lngNum > 180) {
    throw new HttpError(400, 'lng harus berada di antara -180 dan 180')
  }
  return { lat: latNum, lng: lngNum }
}

/**
 * Radius proximity dalam meter, maksimal 500 m.
 */
export function validateRadius(value, fallback = 120) {
  if (value === undefined || value === null || value === '') return fallback
  const radius = Number(value)
  if (!Number.isFinite(radius) || radius <= 0 || radius > 500) {
    throw new HttpError(400, 'radius harus berupa angka antara 1 dan 500 (meter)')
  }
  return radius
}
