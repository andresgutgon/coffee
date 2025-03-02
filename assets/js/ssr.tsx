import ReactDOMServer from 'react-dom/server'
import { createInertiaApp } from '@inertiajs/react'
import type { Page } from '@inertiajs/core'
import { resolvePage } from './utils/pageHelpers'

export function render(page: Page) {
  return createInertiaApp({
    page,
    render: ReactDOMServer.renderToString,
    resolve: resolvePage,
    setup: ({ App, props }) => <App {...props} />,
  })
}
