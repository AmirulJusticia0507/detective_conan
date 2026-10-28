import { defineStore } from 'pinia'
import { api } from '@/api/client'
import { useEpisodeStore } from './episodeStore'

/**
 * Data pemain + inventory. State di sini adalah cache dari server;
 * source of truth tetap backend.
 */
export const usePlayerStore = defineStore('player', {
  state: () => ({
    id: null,
    username: 'Conan',
    position: { x: 357, y: 590 }, // posisi dunia (piksel), di persimpangan jalan
    facing: 'down',
    stamina: 100,
    deductionPoints: 0,
    inventory: [],
    isLoading: false,
    error: null,
  }),

  getters: {
    hasItem: (state) => (itemId) => state.inventory.some((item) => item.id === itemId),
    staminaPercent: (state) => Math.max(0, Math.min(100, state.stamina)),
    collectedEvidenceIds: (state) => state.inventory.map((item) => item.id),
  },

  actions: {
    setPosition(x, y) {
      this.position = { x, y }
    },

    setFacing(direction) {
      this.facing = direction
    },

    async load(playerId = api.PLAYER_ID) {
      this.isLoading = true
      this.error = null
      try {
        const data = await api.getPlayer(playerId)
        this.$patch({
          id: data.id,
          username: data.username,
          stamina: data.stamina,
          deductionPoints: data.deduction_points,
          inventory: (data.inventory ?? []).map((item) => ({
            ...item,
            description: item.description || 'Bukti dari Tempat Kejadian.',
          })),
        })

        // Sinkronkan daftar bukti yang sudah dikumpulkan ke episode store
        const episode = useEpisodeStore()
        episode.collectedEvidenceIds = this.collectedEvidenceIds
        if (!episode.currentEpisode) await episode.loadEpisode(data.current_episode)
      } catch (err) {
        this.error = err.message
      } finally {
        this.isLoading = false
      }
    },

    /** Simpan posisi pemain ke server (lat/lng), dipakai saat interaksi. */
    async syncPositionOnServer(lat, lng) {
      try {
        return await api.savePosition(lat, lng)
      } catch (err) {
        this.error = err.message
        return null
      }
    },

    addItem(item) {
      if (this.hasItem(item.id)) return
      this.inventory.push(item)
    },

    removeItem(itemId) {
      this.inventory = this.inventory.filter((item) => item.id !== itemId)
    },

    spendStamina(amount) {
      this.stamina = Math.max(0, this.stamina - amount)
    },
  },
})
