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
      return state.quests.find((q) => !q.required_evidence_ids.every((id) => done.has(id))) ?? null
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
        await api.collectEvidence(this.currentEpisode?.id, evidenceId)
        this.collectedEvidenceIds.push(evidenceId)
        return true
      } catch (err) {
        this.error = err.message
        return false
      }
    },

    /**
     * Hubungkan dua evidence di deduction board, validasi lewat server.
     */
    async connectEvidence(fromId, toId) {
      const edge = this.deductionEdges.find((e) => e.from === fromId && e.to === toId)
      if (!edge) return { ok: false, reason: 'Tidak ada hubungan deduksi antara kedua bukti.' }
      if (!this.collectedEvidenceIds.includes(fromId)) {
        return { ok: false, reason: 'Bukti asal belum dikumpulkan.' }
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
