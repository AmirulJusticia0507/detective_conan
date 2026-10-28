<script setup>
import { Search, MessageCircle } from 'lucide-vue-next'

const props = defineProps({
  type: { type: String, required: true }, // 'npc' | 'evidence'
  label: { type: String, required: true },
})

defineEmits(['activate'])
</script>

<template>
  <div class="pointer-events-auto px-4 pb-4">
    <button
      type="button"
      class="mx-auto flex max-w-md items-center gap-3 rounded-full border-2 border-beika-gold bg-beika-fog/95 px-5 py-2.5 shadow-panel backdrop-blur transition hover:bg-slate-700"
      @click="$emit('activate')"
    >
      <component :is="props.type === 'npc' ? MessageCircle : Search" class="h-4 w-4 text-beika-gold" />
      <span class="text-sm font-semibold text-slate-100">
        {{ type === 'npc' ? `Bicara dengan ${label}` : label }}
      </span>
      <kbd class="rounded border border-slate-500 px-1.5 py-0.5 text-[10px] text-slate-300">E</kbd>
    </button>
  </div>
</template>
