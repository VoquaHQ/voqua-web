import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    speed: { type: Number, default: 0.3 }
  }

  connect() {
    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener('scroll', this.handleScroll)
    this.handleScroll() // Initial calculation
  }

  disconnect() {
    window.removeEventListener('scroll', this.handleScroll)
  }

  handleScroll() {
    const scrollTop = window.scrollY
    const sectionTop = this.element.offsetTop
    const sectionHeight = this.element.offsetHeight
    const viewportHeight = window.innerHeight
    
    // Check if section is in viewport
    if (scrollTop + viewportHeight >= sectionTop && scrollTop <= sectionTop + sectionHeight) {
      const offset = (scrollTop - sectionTop) * this.speedValue
      this.element.style.setProperty('--scroll-offset', `${offset}px`)
    }
  }
}
