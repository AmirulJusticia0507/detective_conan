import { defineStore } from 'pinia'
import { api } from '@/api/client'

/**
 * Episode aktif, daftar evidence, quest, dan status deduction board.
 */
export const useEpisodeStore = defineStore('episode', {
  state: () => ({
    currentEpisode: null,
    evidence: [],
    quests: [],
    collectedEvidenceIds: [],
    deductionNodes: [],
    deductionEdges: [],
    solvedNodeIds: [],
    activeDialogue: null,
    isLoading: false,
    error: null,
  }),

  getters: {
    collectedEvidence: (state) =>
      state.evidence.filter((e) => state.collectedEvidenceIds.includes(e.id)),
    uncollectedEvidence: (state) =>
      state.evidence.filter((e) => !state.collectedEvidenceIds.includes(e.id)),
    keyEvidenceCollected: (state) =>
      state.evidence
        .filter((e) => e.is_key_evidence)
        .every((e) => state.collectedEvidenceIds.includes(e.id)),
    activeQuest: (state) => {
      const done = new Set(state.solvedNodeIds)
      return (
        state.quests.find((q) => !(q.required_evidence_ids ?? []).every((id) => done.has(id))) ??
        null
      )
    },
  },

  actions: {
    async loadEpisode(episodeId) {
      this.isLoading = true
      this.error = null
      try {
        const data = await api.getEpisode(episodeId)
        this.$patch({
          currentEpisode: data.episode,
          evidence: data.evidence ?? [],
          quests: data.quests ?? [],
          deductionNodes: data.deduction_tree?.nodes ?? [],
          deductionEdges: data.deduction_tree?.edges ?? [],
        })
      } catch (err) {
        this.error = err.message
      } finally {
        this.isLoading = false
      }
    },

    async collect(evidenceId) {
      if (this.collectedEvidenceIds.includes(evidenceId)) return true
      try {
        const result = await api.collectEvidence(evidenceId)
        this.collectedEvidenceIds.push(evidenceId)
        return result
      } catch (err) {
        this.error = err.message
        return false
      }
    },

    /**
     * Hubungkan dua bukti. Server tetap sumber kebenaran; cek lokal hanya
     * untuk umpan balik cepat.
     */
    async connectEvidence(fromId, toId) {
      if (!this.collectedEvidenceIds.includes(fromId)) {
        return { ok: false, reason: 'Bukti asal belum dikumpulkan.' }
      }
      if (!this.currentEpisode) {
        return { ok: false, reason: 'Belum ada episode aktif.' }
      }
      try {
        const res = await api.submitDeduction(this.currentEpisode.id, fromId, toId)
        if (res.ok && !this.solvedNodeIds.includes(toId)) this.solvedNodeIds.push(toId)
        return res
      } catch (err) {
        return { ok: false, reason: err.message }
      }
    },

    openDialogue(dialogue) {
      this.activeDialogue = dialogue
    },

    closeDialogue() {
      this.activeDialogue = null
    },
  },
})
