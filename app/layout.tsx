
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

import { ConnectProvider } from './connectkit-provider'

import {NavBar} from '@/app/ui/NavBar'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'GHOtick',
  description: 'GHO denominated digital asset options',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
      <ConnectProvider>
      <main>

      <NavBar />
      {children}
      </main>
        </ConnectProvider>
     </body>
    </html>
  )
}
