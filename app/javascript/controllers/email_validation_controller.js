import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "error", "button"]

  connect() {
    // Initialize validation state
    this.validateOnSubmit = true
    
    // Add form submit handler
    this.element.addEventListener("submit", this.handleSubmit.bind(this))
  }

  validate() {
    const email = this.inputTarget.value.trim()
    const isValid = this.isValidEmail(email)
    
    if (email === "") {
      // Empty input - hide error but disable submission
      this.errorTarget.classList.add("hidden")
      this.validateOnSubmit = true
      return false
    } else if (!isValid) {
      // Invalid email - show error
      this.errorTarget.classList.remove("hidden")
      this.validateOnSubmit = false
      return false
    } else {
      // Valid email - hide error
      this.errorTarget.classList.add("hidden")
      this.validateOnSubmit = true
      return true
    }
  }

  handleSubmit(event) {
    if (!this.validate()) {
      event.preventDefault()
      
      if (this.inputTarget.value.trim() === "") {
        // If empty, show error message
        this.errorTarget.textContent = "Please enter your email address"
        this.errorTarget.classList.remove("hidden")
        
        // Focus the input field
        this.inputTarget.focus()
      }
    }
  }

  isValidEmail(email) {
    // Basic email validation regex
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }
}
