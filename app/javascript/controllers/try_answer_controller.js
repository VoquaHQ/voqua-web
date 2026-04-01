import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "spinner"]
  static values = { bodyField: String, promptField: String }

  submit() {
    this.buttonTarget.disabled = true
    this.spinnerTarget.classList.remove("hidden")

    // Copy current body and prompt from the edit form into hidden fields
    const bodySource = document.getElementById(this.bodyFieldValue)
    const promptSource = document.getElementById(this.promptFieldValue)

    if (bodySource) {
      this._setHidden("body", bodySource.value)
    }
    if (promptSource) {
      this._setHidden("prompt", promptSource.value)
    }
  }

  complete() {
    this.buttonTarget.disabled = false
    this.spinnerTarget.classList.add("hidden")
  }

  _setHidden(name, value) {
    let input = this.element.querySelector(`input[name="${name}"]`)
    if (!input) {
      input = document.createElement("input")
      input.type = "hidden"
      input.name = name
      this.element.appendChild(input)
    }
    input.value = value
  }
}
