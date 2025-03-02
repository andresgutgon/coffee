import tailwindForms from '@tailwindcss/forms'

export default {
  content: ['./js/**/*.ts', './js/**/*.tsx'],
  theme: {
    extend: {
      colors: {
        brand: '#FD4F00',
      },
    },
  },
  plugins: [tailwindForms],
}
