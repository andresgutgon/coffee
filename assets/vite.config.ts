import path from 'node:path'
import type { BuildEnvironmentOptions, ConfigEnv } from 'vite'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
const isSSR = process.env.VITE_SSR === 'true'

const ALIAS = {
  '@': path.resolve(__dirname, './js'),
}
const PLUGINS = [react()]
export default defineConfig(({ command }: ConfigEnv) => {
  const isDev = command !== 'build'

  if (isDev) {
    // Terminate the watcher when Phoenix quits
    process.stdin.on('close', () => {
      process.exit(0)
    })

    process.stdin.resume()
  }

  if (isSSR) {
    return {
      root: path.resolve(__dirname, 'js'),
      plugins: PLUGINS,
      build: {
        ssr: 'ssr.tsx',
        outDir: '../../priv',
        sourcemap: isDev
          ? ('inline' as BuildEnvironmentOptions['sourcemap'])
          : false,
        minify: false,
        rollupOptions: {
          external: ['fonts/*', 'images/*'],
        },
      },
      resolve: {
        alias: ALIAS,
      },
      ssr: {
        noExternal: true as const,
      },
    }
  } else {
    return {
      plugins: PLUGINS,
      publicDir: 'static',
      resolve: {
        alias: {
          '@': path.resolve(__dirname, './js'),
        },
      },
      build: {
        outDir: '../priv/static',
        emptyOutDir: false,
        target: 'esnext',
        polyfillDynamicImport: true,
        manifest: 'vite_manifest.json',
        sourcemap: isDev
          ? ('inline' as BuildEnvironmentOptions['sourcemap'])
          : false,
        minify: !isDev,
        rollupOptions: {
          input: {
            app: 'js/app.tsx',
          },
          output: {
            entryFileNames: 'assets/[name].[hash].js',
            chunkFileNames: 'assets/[name].[hash].js',
            assetFileNames: 'assets/[name].[hash][extname]',
          },
          external: ['fonts/*', 'images/*'],
        },
      },
    }
  }
})
