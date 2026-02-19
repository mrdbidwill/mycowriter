import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Wait for Trix to be loaded
    if (typeof window.Trix !== 'undefined') {
      this.setupPasteHandler()
    } else {
      // If Trix isn't loaded yet, wait for it
      document.addEventListener('trix-initialize', () => {
        this.setupPasteHandler()
      }, { once: true })
    }
  }

  setupPasteHandler() {
    const trixEditor = this.element.querySelector('trix-editor')
    if (!trixEditor) return

    this.trixEditor = trixEditor

    // Listen for the trix-paste event
    trixEditor.addEventListener('trix-paste', (event) => {
      const { paste } = event

      // Handle plain text pastes
      if (paste.string && !paste.html) {
        event.preventDefault()

        const cleaned = this.cleanText(paste.string)

        // Insert the cleaned text
        const { editor } = trixEditor
        editor.insertString(cleaned)
      }
    })
  }

  cleanText(text) {
    // Remove hyphenated line breaks: "as-\ncomycetes" -> "ascomycetes"
    text = text.replace(/(\w)-\s*[\r\n]+\s*/g, '$1')

    // Replace single newlines with spaces (joins wrapped lines)
    // But preserve double newlines (paragraph breaks)
    text = text.replace(/([^\n])\r?\n([^\n])/g, '$1 $2')

    // Collapse 3+ newlines to 2 (paragraph breaks)
    text = text.replace(/[\r\n]{3,}/g, '\n\n')

    // Clean up spaces
    text = text.replace(/ +/g, ' ')

    return text.trim()
  }

  disconnect() {
    // Cleanup is handled automatically by Stimulus
  }
}
