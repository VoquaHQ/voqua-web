import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    text: String,
    glitchInterval: { type: Number, default: 3000 },
    glitchDuration: { type: Number, default: 200 }
  }

  connect() {
    this.originalText = this.textValue || this.element.textContent
    this.startGlitching()
  }

  disconnect() {
    this.stopGlitching()
  }

  startGlitching() {
    this.glitchIntervalId = setInterval(() => {
      this.applyGlitchEffect()
    }, this.glitchIntervalValue)
  }

  stopGlitching() {
    if (this.glitchIntervalId) {
      clearInterval(this.glitchIntervalId)
    }
    if (this.glitchEffectId) {
      clearInterval(this.glitchEffectId)
    }
  }

  applyGlitchEffect() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+{}|:<>?'
    this.element.classList.add('text-red-500')
    
    let glitchCount = 0
    const maxGlitches = 5
    
    this.glitchEffectId = setInterval(() => {
      const text = this.originalText.split('').map((char) => {
        // Skip spaces and randomly decide which characters to glitch
        if (char === ' ' || Math.random() > 0.5) return char
        
        return characters.charAt(Math.floor(Math.random() * characters.length))
      }).join('')
      
      this.element.textContent = text
      
      glitchCount++
      
      if (glitchCount >= maxGlitches) {
        clearInterval(this.glitchEffectId)
        
        // Reset to original text
        setTimeout(() => {
          this.element.textContent = this.originalText
          this.element.classList.remove('text-red-500')
        }, 100)
      }
    }, 50)
    
    // Clear glitch effect after duration
    setTimeout(() => {
      if (this.glitchEffectId) {
        clearInterval(this.glitchEffectId)
      }
      this.element.textContent = this.originalText
      this.element.classList.remove('text-red-500')
    }, this.glitchDurationValue)
  }
}
