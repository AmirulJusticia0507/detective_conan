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

    /** Sinkronkan state hasil respons backend (inventory + poin). */
    applyServerState({ inventory, deduction_points }) {
      if (Array.isArray(inventory)) {
        this.inventory = inventory.map((item) => ({
          ...item,
          description: item.description || 'Bukti dari Tempat Kejadian.',
        }))
      }
      if (typeof deduction_points === 'number') this.deductionPoints = deduction_points
    },

    setFacing(direction) {
      this.facing = direction
    },

    async load(playerId = api.PLAYER_ID) {
      this.isLoading = true
      this.error = null
      try {
        const data = await api.getPlayer(playerId)

        // Muat episode lebih dulu agar deskripsi inventory bisa dilengkapi
        // dari data evidence.
        const episode = useEpisodeStore()
        if (!episode.currentEpisode) await episode.loadEpisode(data.current_episode)

        this.$patch({
          id: data.id,
          username: data.username,
          stamina: data.stamina,
          deductionPoints: data.deduction_points,
          inventory: (data.inventory ?? []).map((item) => ({
            ...item,
            description:
              item.description ||
              episode.evidence.find((e) => e.id === item.id)?.description ||
              'Bukti dari Tempat Kejadian.',
          })),
        })

        episode.collectedEvidenceIds = this.collectedEvidenceIds
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
