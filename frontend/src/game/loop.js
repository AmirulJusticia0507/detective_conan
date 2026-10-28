/**
 * Game loop + input. Dijalankan dari MapViewport.
 * Kecepatan dalam piksel per detik, gerak dinormalisasi agar diagonal tidak lebih cepat.
 */

export const PLAYER_SPEED = 180 // px/detik

const KEY_MAP = {
  ArrowUp: 'up',
  ArrowDown: 'down',
  ArrowLeft: 'left',
  ArrowRight: 'right',
  w: 'up',
  s: 'down',
  a: 'left',
  d: 'right',
}

export function createLoop({ onUpdate }) {
  const pressed = new Set()
  let rafId = 0
  let last = 0
  let running = false

  function shouldIgnoreInput(event) {
    const tag = event.target?.tagName
    return tag === 'INPUT' || tag === 'TEXTAREA' || event.target?.isContentEditable
  }

  function onKeyDown(event) {
    const dir = KEY_MAP[event.key]
    if (!dir || shouldIgnoreInput(event)) return
    event.preventDefault()
    pressed.add(dir)
  }

  function onKeyUp(event) {
    const dir = KEY_MAP[event.key]
    if (dir) pressed.delete(dir)
  }

  function onBlur() {
    pressed.clear()
  }

  function frame(now) {
    if (!running) return
    const dt = Math.min((now - last) / 1000, 0.1)
    last = now
    onUpdate(dt, pressed)
    rafId = requestAnimationFrame(frame)
  }

  function start() {
    if (running) return
    running = true
    last = performance.now()
    window.addEventListener('keydown', onKeyDown)
    window.addEventListener('keyup', onKeyUp)
    window.addEventListener('blur', onBlur)
    rafId = requestAnimationFrame(frame)
  }

  function stop() {
    running = false
    cancelAnimationFrame(rafId)
    window.removeEventListener('keydown', onKeyDown)
    window.removeEventListener('keyup', onKeyUp)
    window.removeEventListener('blur', onBlur)
    pressed.clear()
  }

  return { start, stop }
}

/**
 * Hitung pergeseran dari tombol yang aktif.
 * @returns {{dx:number, dy:number, facing:string|null}}
 */
export function readMovement(pressed, speed, dt) {
  let dx = 0
  let dy = 0
  if (pressed.has('up')) dy -= 1
  if (pressed.has('down')) dy += 1
  if (pressed.has('left')) dx -= 1
  if (pressed.has('right')) dx += 1

  if (dx === 0 && dy === 0) return { dx: 0, dy: 0, facing: null }

  const len = Math.hypot(dx, dy)
  dx = (dx / len) * speed * dt
  dy = (dy / len) * speed * dt

  let facing = 'down'
  if (Math.abs(dy) > Math.abs(dx)) facing = dy < 0 ? 'up' : 'down'
  else facing = dx < 0 ? 'left' : 'right'

  return { dx, dy, facing }
}
