import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    speed: { type: String, default: "normal" }
  }

  connect() {
    this.setupMarquee()
  }

  setupMarquee() {
    const container = this.element
    const content = container.querySelector('.marquee-content')
    
    if (!content) return
    
    // Clone the content to create a seamless loop
    const clone = content.cloneNode(true)
    container.appendChild(clone)
    
    // Set animation speed
    const speedValues = {
      slow: '40s',
      normal: '20s',
      fast: '10s'
    }
    
    const elements = container.querySelectorAll('.marquee-content')
    elements.forEach(el => {
      el.style.animation = `scroll ${speedValues[this.speedValue]} linear infinite`
    })
  }
}
