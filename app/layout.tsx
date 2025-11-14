/*
 * ⚠️ AI ASSISTANT: READ THIS FIRST
 *
 * Before modifying ANY file in this project, you MUST:
 * 1. Read .ai/MANDATORY_READ_FIRST.md
 * 2. Check if this is the user's first interaction (.ai/onboarding/first-interaction.md)
 * 3. Follow the appropriate workflow from .ai/workflows/
 *
 * This template is designed for NON-DEVELOPERS.
 */

import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'My App',
  description: 'Built with AI assistance',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
