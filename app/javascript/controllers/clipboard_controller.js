import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { content: String }

  copy() {
    navigator.clipboard.writeText(this.contentValue).then(() => {
      this.#showFeedback()
    })
  }

  #showFeedback() {
    const original = this.element.textContent
    this.element.textContent = "✓ Copiado!"
    setTimeout(() => {
      this.element.textContent = original
    }, 1500)
  }
}
