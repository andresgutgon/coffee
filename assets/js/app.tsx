import axios from 'axios'

import { createInertiaApp } from '@inertiajs/react'
import { createRoot, hydrateRoot } from 'react-dom/client'
import { resolvePage } from './utils/pageHelpers'

axios.defaults.xsrfHeaderName = 'x-csrf-token'

createInertiaApp({
  resolve: resolvePage,
  setup({ App, el, props }) {
    if (props.initialPage.props.ssr) {
      hydrateRoot(el, <App {...props} />)
    } else {
      createRoot(el).render(<App {...props} />)
    }
  },
})
