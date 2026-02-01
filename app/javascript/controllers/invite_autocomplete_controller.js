import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }
  static targets = ["input", "results"]

  connect() {
    this.abortController = null
    this.lastQuery = ""
    this.hideTimer = null
    this.activeIndex = -1
    this.optionIdCounter = 0
  }

  disconnect() {
    this.abortController?.abort()
    clearTimeout(this.hideTimer)
  }

  suggest() {
    if (!this.hasInputTarget) return
    const input = this.inputTarget
    const query = input.value.trim().toLowerCase()

    if (event.inputType === "deleteContentBackward") {
      this.lastQuery = query
      return
    }

    if (query.length < 2 || query === this.lastQuery) {
      this.renderResults([])
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
        this.renderResults(Array.isArray(emails) ? emails : [])
      })
      .catch((error) => {
        if (error.name !== "AbortError") throw error
      })
  }

  navigate(event) {
    if (!this.hasResultsTarget || this.resultsTarget.classList.contains("hidden")) return

    const options = this.optionElements()
    if (options.length === 0) return

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.setActiveIndex((this.activeIndex + 1) % options.length)
        break
      case "ArrowUp":
        event.preventDefault()
        this.setActiveIndex((this.activeIndex - 1 + options.length) % options.length)
        break
      case "Enter":
        if (this.activeIndex >= 0 && options[this.activeIndex]) {
          event.preventDefault()
          options[this.activeIndex].click()
        }
        break
      case "Escape":
        event.preventDefault()
        this.renderResults([])
        break
    }
  }

  select(event) {
    const email = event.currentTarget.dataset.email
    if (!email) return

    this.inputTarget.value = email
    this.renderResults([])
    this.inputTarget.focus()
  }

  hide() {
    clearTimeout(this.hideTimer)
    this.hideTimer = setTimeout(() => this.renderResults([]), 150)
  }

  show() {
    clearTimeout(this.hideTimer)
    if (this.resultsTarget.children.length > 0) {
      this.resultsTarget.classList.remove("hidden")
      this.inputTarget.setAttribute("aria-expanded", "true")
    }
  }

  renderResults(emails) {
    if (!this.hasResultsTarget) return

    this.resultsTarget.innerHTML = ""
    this.activeIndex = -1
    this.inputTarget.removeAttribute("aria-activedescendant")
    if (emails.length === 0) {
      this.resultsTarget.classList.add("hidden")
      this.inputTarget.setAttribute("aria-expanded", "false")
      return
    }

    emails.forEach((email) => {
      const item = document.createElement("button")
      item.type = "button"
      item.dataset.email = email
      this.optionIdCounter += 1
      item.id = `invite-autocomplete-option-${this.optionIdCounter}`
      item.setAttribute("role", "option")
      item.setAttribute("aria-selected", "false")
      item.className =
        "block w-full text-left px-3 py-2 text-sm text-slate-200 hover:bg-slate-800/70"
      item.textContent = email
      item.addEventListener("mousedown", (event) => event.preventDefault())
      item.addEventListener("click", (event) => this.select(event))
      this.resultsTarget.appendChild(item)
    })

    this.resultsTarget.classList.remove("hidden")
    this.inputTarget.setAttribute("aria-expanded", "true")
  }

  optionElements() {
    return Array.from(this.resultsTarget.querySelectorAll('[role="option"]'))
  }

  setActiveIndex(index) {
    const options = this.optionElements()
    if (options.length === 0) return

    options.forEach((option, idx) => {
      const active = idx === index
      option.setAttribute("aria-selected", active ? "true" : "false")
      option.classList.toggle("bg-slate-800/70", active)
      option.classList.toggle("text-white", active)
    })

    this.activeIndex = index
    const activeOption = options[index]
    if (activeOption) {
      this.inputTarget.setAttribute("aria-activedescendant", activeOption.id)
      activeOption.scrollIntoView({ block: "nearest" })
    }
  }
}
