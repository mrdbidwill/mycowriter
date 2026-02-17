import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = {
    url: { type: String, default: "/autocomplete/taxa" },
    minChars: { type: Number, default: 2 }
  }

  connect() {
    this.selectedIndex = -1
    this.timeout = null
    this.abortController = null
  }

  disconnect() {
    this.hideResults()
    if (this.timeout) clearTimeout(this.timeout)
    if (this.abortController) this.abortController.abort()
  }

  search(event) {
    if (this.timeout) clearTimeout(this.timeout)

    if (['ArrowDown', 'ArrowUp', 'Enter', 'Escape'].includes(event.key)) {
      this.handleKeyNavigation(event)
      return
    }

    const query = this.getCurrentWord()

    if (query.length < this.minCharsValue) {
      this.hideResults()
      return
    }

    this.timeout = setTimeout(() => {
      this.fetchResults(query)
    }, 300)
  }

  getCurrentWord() {
    const input = this.inputTarget
    const text = input.value
    const cursorPos = input.selectionStart

    let start = cursorPos
    while (start > 0 && !/\s/.test(text[start - 1])) {
      start--
    }

    let end = cursorPos
    while (end < text.length && !/\s/.test(text[end])) {
      end++
    }

    return text.substring(start, end).trim()
  }

  async fetchResults(query) {
    if (this.abortController) this.abortController.abort()
    this.abortController = new AbortController()

    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
        signal: this.abortController.signal,
        headers: { 'Accept': 'application/json' }
      })

      if (!response.ok) throw new Error('Failed to fetch results')

      const results = await response.json()
      this.displayResults(results)
    } catch (error) {
      if (error.name !== 'AbortError') {
        console.error('Autocomplete error:', error)
        this.hideResults()
      }
    }
  }

  displayResults(results) {
    console.log('displayResults called with:', results)

    if (!results || results.length === 0) {
      console.log('No results, hiding')
      this.hideResults()
      return
    }

    this.selectedIndex = -1

    const html = results.map((result, index) => `
      <div class="autocomplete-result-item" data-index="${index}" data-value="${this.escapeHtml(result.value)}">
        <div class="font-medium text-gray-900">${this.escapeHtml(result.value)}</div>
        <div class="text-xs text-gray-500">${this.escapeHtml(result.label)}${result.authors ? ' — ' + this.escapeHtml(result.authors) : ''}</div>
      </div>
    `).join('')

    console.log('Setting innerHTML and removing hidden class')
    this.resultsTarget.innerHTML = html
    this.resultsTarget.classList.remove('hidden')
    console.log('Results target classes:', this.resultsTarget.classList.toString())

    this.resultsTarget.querySelectorAll('.autocomplete-result-item').forEach(item => {
      item.addEventListener('click', (e) => this.selectResult(e))
      item.addEventListener('mouseenter', (e) => this.highlightResult(e))
    })

    this.positionResults()
  }

  hideResults() {
    if (this.hasResultsTarget) {
      this.resultsTarget.classList.add('hidden')
      this.resultsTarget.innerHTML = ''
    }
    this.selectedIndex = -1
  }

  positionResults() {
    if (!this.hasResultsTarget || !this.hasInputTarget) return
    const inputRect = this.inputTarget.getBoundingClientRect()

    // Get cursor position in textarea
    const textarea = this.inputTarget
    const cursorPos = textarea.selectionStart

    // Create a mirror div to calculate cursor position
    const mirror = document.createElement('div')
    const computed = window.getComputedStyle(textarea)
    mirror.style.cssText = `
      position: absolute;
      visibility: hidden;
      white-space: pre-wrap;
      word-wrap: break-word;
      font-family: ${computed.fontFamily};
      font-size: ${computed.fontSize};
      line-height: ${computed.lineHeight};
      padding: ${computed.padding};
      width: ${inputRect.width}px;
    `
    mirror.textContent = textarea.value.substring(0, cursorPos)
    document.body.appendChild(mirror)

    const mirrorRect = mirror.getBoundingClientRect()
    const lineHeight = parseInt(computed.lineHeight)
    document.body.removeChild(mirror)

    // Position dropdown at cursor location
    this.resultsTarget.style.top = `${inputRect.top + mirrorRect.height + lineHeight}px`
    this.resultsTarget.style.left = `${inputRect.left + 10}px`
    this.resultsTarget.style.maxWidth = `${Math.min(inputRect.width - 20, 500)}px`
  }

  handleKeyNavigation(event) {
    const items = this.resultsTarget.querySelectorAll('.autocomplete-result-item')
    if (items.length === 0) return

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.updateHighlight(items)
        break
      case 'ArrowUp':
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
        this.updateHighlight(items)
        break
      case 'Enter':
        event.preventDefault()
        if (this.selectedIndex >= 0) {
          this.selectResultByIndex(this.selectedIndex)
        }
        break
      case 'Escape':
        event.preventDefault()
        this.hideResults()
        break
    }
  }

  updateHighlight(items) {
    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add('active')
        item.scrollIntoView({ block: 'nearest' })
      } else {
        item.classList.remove('active')
      }
    })
  }

  highlightResult(event) {
    const items = this.resultsTarget.querySelectorAll('.autocomplete-result-item')
    items.forEach(item => item.classList.remove('active'))
    event.currentTarget.classList.add('active')
    this.selectedIndex = parseInt(event.currentTarget.dataset.index)
  }

  selectResult(event) {
    const value = event.currentTarget.dataset.value
    this.insertValue(value)
  }

  selectResultByIndex(index) {
    const items = this.resultsTarget.querySelectorAll('.autocomplete-result-item')
    if (items[index]) {
      const value = items[index].dataset.value
      this.insertValue(value)
    }
  }

  insertValue(value) {
    const input = this.inputTarget
    const start = input.selectionStart
    const end = input.selectionEnd
    const text = input.value

    let wordStart = start
    while (wordStart > 0 && !/\s/.test(text[wordStart - 1])) {
      wordStart--
    }

    const before = text.substring(0, wordStart)
    const after = text.substring(end)
    input.value = before + value + ' ' + after

    const newPos = wordStart + value.length + 1
    input.setSelectionRange(newPos, newPos)
    input.focus()

    this.hideResults()
    input.dispatchEvent(new Event('input', { bubbles: true }))
  }

  blur(event) {
    setTimeout(() => {
      this.hideResults()
    }, 300)
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
