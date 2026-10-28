let enabled = true
let context

export function setSoundEnabled(value) {
  enabled = value
}

export function playTone(frequency, duration = 0.08) {
  if (!enabled) return
  const AudioContext = window.AudioContext || window.webkitAudioContext
  if (!AudioContext) return

  context ??= new AudioContext()
  if (context.state === 'suspended') context.resume()
  const oscillator = context.createOscillator()
  const gain = context.createGain()
  oscillator.frequency.value = frequency
  gain.gain.setValueAtTime(0.06, context.currentTime)
  gain.gain.exponentialRampToValueAtTime(0.001, context.currentTime + duration)
  oscillator.connect(gain).connect(context.destination)
  oscillator.start()
  oscillator.stop(context.currentTime + duration)
}
