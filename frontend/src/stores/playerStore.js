import { defineStore } from 'pinia'
import { api } from '@/api/client'

/**
 * Data pemain + inventory. State di sini adalah cache dari server;
 * source of truth tetap backend.
 */
export const usePlayerStore = defineStore('player', {
  state: () => ({
    id: null,
    username: 'Conan',
    position: { x: 0, y: 0 }, // koordinat dunia (tile), bukan lat/lng
    stamina: 100,
    deductionPoints: 0,
    inventory: [],
    isLoading: false,
    error: null,
  }),

  getters: {
    hasItem: (state) => (itemId) =>
      state.inventory.some((item) => item.id === itemId),
    staminaPercent: (state) => Math.max(0, Math.min(100, state.stamina)),
  },

  actions: {
    setPosition(x, y) {
      this.position = { x, y }
    },

    async load(playerId) {
      this.isLoading = true
      this.error = null
      try {
        const data = await api.getPlayer(playerId)
        this.$patch({
          id: data.id,
          username: data.username,
          stamina: data.stamina,
          deductionPoints: data.deduction_points,
          inventory: data.inventory ?? [],
          position: data.world_position ?? this.position,
        })
      } catch (err) {
        this.error = err.message
      } finally {
        this.isLoading = false
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
