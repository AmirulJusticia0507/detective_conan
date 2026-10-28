import { defineStore } from 'pinia'
import { WORLD } from '@/game/worldData'

/**
 * State peta: ukuran dunia, kamera, dan area aktif.
 * Renderer membaca dari sini, bukan menyimpan state sendiri.
 */
export const useMapStore = defineStore('map', {
  state: () => ({
    worldWidth: WORLD.width,
    worldHeight: WORLD.height,
    camera: { x: 0, y: 0 },
    currentAreaId: 'beika-street',
  }),

  actions: {
    /**
     * Pusatkan kamera pada target, dibatasi tepi peta.
     * @param {{x:number,y:number}} target posisi dunia piksel
     * @param {{width:number,height:number}} viewport ukuran layar piksel
     */
    centerCameraOn(target, viewport) {
      const maxX = Math.max(0, this.worldWidth - viewport.width)
      const maxY = Math.max(0, this.worldHeight - viewport.height)
      this.camera.x = clamp(target.x - viewport.width / 2, 0, maxX)
      this.camera.y = clamp(target.y - viewport.height / 2, 0, maxY)
    },

    setArea(areaId) {
      this.currentAreaId = areaId
    },
  },
})

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max)
}
