import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["password", "confirmation", "error", "submit"]

  connect() {
    // Initialize validation state
    this.validate()
  }

  validate() {
    const password = this.passwordTarget.value
    const confirmation = this.confirmationTarget.value
    const error = this.errorTarget
    const submit = this.submitTarget

    if (confirmation.length > 0 && password !== confirmation) {
      error.classList.remove("hidden")
      submit.disabled = true
      submit.classList.add("opacity-50", "cursor-not-allowed")
    } else {
      error.classList.add("hidden")
      submit.disabled = false
      submit.classList.remove("opacity-50", "cursor-not-allowed")
    }
  }
}
