/**
 * Konversi koordinat dunia game (piksel) ke lat/lng WGS84 di area Distrik Beika.
 * Titik acuan: pusat Distrik Beika (sekitar Beika, Tokyo).
 *
 * Ini koordinat fiktif untuk gameplay, bukan lokasi nyata.
 */

const BEIKA_ORIGIN = { lat: 35.6762, lng: 139.6503 }

// 1 piksel dunia = 1 meter (skala reka-reka, cukup untuk ST_DWithin).
const METERS_PER_PIXEL = 1

const METERS_PER_DEG_LAT = 111_320

/**
 * @param {{x:number,y:number}} position posisi dunia piksel
 * @param {number} worldWidth lebar dunia piksel
 * @param {number} worldHeight tinggi dunia piksel
 */
export function worldToLatLng(position, worldWidth, worldHeight) {
  // Piksel (0,0) = sudut kiri atas peta = barat laut koordinat acuan.
  const eastMeters = (position.x - worldWidth / 2) * METERS_PER_PIXEL
  const southMeters = (position.y - worldHeight / 2) * METERS_PER_PIXEL

  const lat = BEIKA_ORIGIN.lat - southMeters / METERS_PER_DEG_LAT
  const lng =
    BEIKA_ORIGIN.lng + eastMeters / (METERS_PER_DEG_LAT * Math.cos((BEIKA_ORIGIN.lat * Math.PI) / 180))

  return {
    lat: Number(lat.toFixed(6)),
    lng: Number(lng.toFixed(6)),
  }
}

/**
 * Kebalikannya: lat/lng -> posisi dunia piksel.
 */
export function latLngToWorld({ lat, lng }, worldWidth, worldHeight) {
  const southMeters = (BEIKA_ORIGIN.lat - lat) * METERS_PER_DEG_LAT
  const eastMeters =
    (lng - BEIKA_ORIGIN.lng) * METERS_PER_DEG_LAT * Math.cos((BEIKA_ORIGIN.lat * Math.PI) / 180)

  return {
    x: eastMeters / METERS_PER_PIXEL + worldWidth / 2,
    y: southMeters / METERS_PER_PIXEL + worldHeight / 2,
  }
}
