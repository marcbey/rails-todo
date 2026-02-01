import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.abortController = null
    this.lastQuery = ""
  }

  disconnect() {
    this.abortController?.abort()
  }

  suggest(event) {
    const input = event.target
    const query = input.value.trim().toLowerCase()

    if (event.inputType === "deleteContentBackward") {
      this.lastQuery = query
      return
    }

    if (query.length < 2 || query === this.lastQuery) {
      return
    }

    this.lastQuery = query

    this.abortController?.abort()
    this.abortController = new AbortController()

    fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
      headers: { Accept: "application/json" },
      signal: this.abortController.signal
    })
      .then((response) => (response.ok ? response.json() : []))
      .then((emails) => {
        if (!Array.isArray(emails) || emails.length === 0) return

        const match = emails[0]
        if (!match || !match.toLowerCase().startsWith(query)) return

        // Only auto-complete if cursor is at end.
        if (input.selectionStart !== input.selectionEnd || input.selectionEnd !== input.value.length) return

        input.value = match
        input.setSelectionRange(query.length, match.length)
      })
      .catch((error) => {
        if (error.name !== "AbortError") throw error
      })
  }
}
