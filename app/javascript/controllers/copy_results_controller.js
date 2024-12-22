import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  copy() {
    const text = this.sourceTarget.value
    navigator.clipboard.writeText(text).then(() => {
      const button = this.buttonTarget
      button.textContent = "Copied!"
      
      setTimeout(() => {
        button.textContent = "Copy results to clipboard"
      }, 1500)
    })
  }
}
