
import { Inter } from 'next/font/google'
import './globals.css'

import { ConnectProvider } from './connectkit-provider'
import {NavBar} from '@/app/ui/NavBar'

// const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: 'GHOptim',
  description: 'GHO optimal options',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
      
      <ConnectProvider>

<NavBar />
<br></br>
<div className="container-main">

{children}
</div>
  </ConnectProvider>
      
     </body>
    </html>
  )
}
