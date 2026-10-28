/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{vue,js}'],
  theme: {
    extend: {
      colors: {
        // Palet Detective Conan
        beika: {
          navy: '#1e3a8a',
          red: '#dc2626',
          gold: '#facc15',
          ink: '#0f172a',
          fog: '#1e293b',
        },
      },
      fontFamily: {
        detective: ['"Playfair Display"', 'Georgia', 'serif'],
      },
      boxShadow: {
        panel: '0 12px 32px -8px rgba(0, 0, 0, 0.6)',
      },
    },
  },
  plugins: [],
}
