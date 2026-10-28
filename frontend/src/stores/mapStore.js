import { defineStore } from 'pinia'

/**
 * State peta: tile size, kamera, dan area yang sudah dimuat.
 * Renderer membaca dari sini, bukan menyimpan state sendiri.
 */
export const useMapStore = defineStore('map', {
  state: () => ({
    tileSize: 32,
    mapWidth: 64, // tile
    mapHeight: 48, // tile
    camera: { x: 0, y: 0 },
    currentAreaId: 'beika-street',
  }),

  getters: {
    worldWidth: (state) => state.mapWidth * state.tileSize,
    worldHeight: (state) => state.mapHeight * state.tileSize,
  },

  actions: {
    /**
     * Pusatkan kamera pada target, dibatasi tepi peta.
     * @param {{x:number,y:number}} target posisi dunia piksel
     * @param {{width:number,height:number}} viewport ukuran layar piksel
     */
    centerCameraOn(target, viewport) {
      const halfW = viewport.width / 2
      const halfH = viewport.height / 2
      this.camera.x = clamp(target.x - halfW, 0, Math.max(0, this.worldWidth - viewport.width))
      this.camera.y = clamp(target.y - halfH, 0, Math.max(0, this.worldHeight - viewport.height))
    },

    setArea(areaId) {
      this.currentAreaId = areaId
    },
  },
})

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max)
}
