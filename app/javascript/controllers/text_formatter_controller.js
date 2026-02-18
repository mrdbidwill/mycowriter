import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "charCount"]
  static values = { maxLength: { type: Number, default: 16777215 } }

  connect() {
    this.updateCharCount()
  }

  insertParagraph() {
    const textarea = this.textareaTarget
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const value = textarea.value

    // Insert double newline for paragraph break
    const newValue = value.substring(0, start) + '\n\n' + value.substring(end)
    textarea.value = newValue

    // Move cursor after the inserted newlines
    const newPos = start + 2
    textarea.setSelectionRange(newPos, newPos)
    textarea.focus()

    // Trigger input event
    textarea.dispatchEvent(new Event('input', { bubbles: true }))
  }

  makeBold() {
    this.wrapSelection('**', '**')
  }

  makeItalic() {
    this.wrapSelection('*', '*')
  }

  makeUnderline() {
    this.wrapSelection('<u>', '</u>')
  }

  makeStrikethrough() {
    this.wrapSelection('~~', '~~')
  }

  makeH1() {
    this.insertLinePrefix('# ')
  }

  makeH2() {
    this.insertLinePrefix('## ')
  }

  makeH3() {
    this.insertLinePrefix('### ')
  }

  makeBulletList() {
    this.insertLinePrefix('- ')
  }

  makeNumberedList() {
    this.insertLinePrefix('1. ')
  }

  insertLink() {
    const textarea = this.textareaTarget
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const value = textarea.value
    const selectedText = value.substring(start, end)

    if (selectedText) {
      // Wrap selected text as link
      const newValue = value.substring(0, start) + '[' + selectedText + '](url)' + value.substring(end)
      textarea.value = newValue
      // Select "url" for easy replacement
      const urlStart = start + selectedText.length + 3
      textarea.setSelectionRange(urlStart, urlStart + 3)
    } else {
      // Insert link template
      const linkText = '[link text](url)'
      const newValue = value.substring(0, start) + linkText + value.substring(end)
      textarea.value = newValue
      // Select "link text" for easy replacement
      textarea.setSelectionRange(start + 1, start + 10)
    }

    textarea.focus()
    textarea.dispatchEvent(new Event('input', { bubbles: true }))
  }

  insertLinePrefix(prefix) {
    const textarea = this.textareaTarget
    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const value = textarea.value

    // Find the start of the current line
    let lineStart = start
    while (lineStart > 0 && value[lineStart - 1] !== '\n') {
      lineStart--
    }

    // Insert prefix at the start of the line
    const newValue = value.substring(0, lineStart) + prefix + value.substring(lineStart)
    textarea.value = newValue

    // Move cursor after the prefix
    const newPos = start + prefix.length
    textarea.setSelectionRange(newPos, newPos)
    textarea.focus()
    textarea.dispatchEvent(new Event('input', { bubbles: true }))
  }

  wrapSelection(before, after) {
    const textarea = this.textareaTarget

    // Ensure textarea has focus first
    textarea.focus()

    const start = textarea.selectionStart
    const end = textarea.selectionEnd
    const value = textarea.value
    const selectedText = value.substring(start, end)

    // If no selection, insert markers with cursor between
    if (start === end) {
      const newValue = value.substring(0, start) + before + after + value.substring(end)
      textarea.value = newValue
      const newPos = start + before.length
      textarea.setSelectionRange(newPos, newPos)
    } else {
      // Wrap selected text
      const newValue = value.substring(0, start) + before + selectedText + after + value.substring(end)
      textarea.value = newValue
      textarea.setSelectionRange(start + before.length, end + before.length)
    }

    textarea.dispatchEvent(new Event('input', { bubbles: true }))
  }

  updateCharCount() {
    if (!this.hasCharCountTarget) return

    const length = this.textareaTarget.value.length
    const max = this.maxLengthValue
    const remaining = max - length
    const percent = (length / max) * 100

    this.charCountTarget.textContent = `${length.toLocaleString()} / ${max.toLocaleString()} characters`

    // Change color based on usage
    if (percent >= 95) {
      this.charCountTarget.className = 'text-xs font-medium text-red-600'
    } else if (percent >= 80) {
      this.charCountTarget.className = 'text-xs font-medium text-yellow-600'
    } else {
      this.charCountTarget.className = 'text-xs text-gray-500'
    }

    // Warn if exceeding limit
    if (length > max) {
      alert(`Content is too large (${length.toLocaleString()} characters). Maximum is ${max.toLocaleString()} characters. Please reduce the content size.`)
    }
  }
}
