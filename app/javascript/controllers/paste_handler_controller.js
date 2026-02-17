
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  cleanPaste(event) {
    // Prevent the default paste behavior
    event.preventDefault()

    // Get the plain text from clipboard
    const text = (event.clipboardData || window.clipboardData).getData('text')

    // Clean the text:
    // 1. Remove end-of-line hyphens (e.g., "as-\ncomycetes" becomes "ascomycetes")
    // 2. Normalize whitespace
    const cleaned = text
      .replace(/-\s*\n\s*/g, '') // Remove hyphen followed by newline
      .replace(/\r\n/g, '\n')     // Normalize line endings
      .trim()

    // Insert the cleaned text at cursor position
    const target = event.target
    const start = target.selectionStart
    const end = target.selectionEnd
    const currentValue = target.value

    target.value = currentValue.substring(0, start) + cleaned + currentValue.substring(end)

    // Set cursor position after inserted text
    const newCursorPos = start + cleaned.length
    target.setSelectionRange(newCursorPos, newCursorPos)

    // Trigger input event so other listeners know the value changed
    target.dispatchEvent(new Event('input', { bubbles: true }))
  }
}
