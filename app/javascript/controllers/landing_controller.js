import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fadeIn"]

  connect() {
    // Subtle fade in for main header
    this.fadeInTarget.setAttribute("data-show", "true")
    
    // Trigger animations as elements enter viewport
    this.setupScrollAnimations()
  }
  
  setupScrollAnimations() {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('animate-in')
          }
        })
      },
      { threshold: 0.1 }
    )

    document.querySelectorAll('.animate-on-scroll').forEach((el) => {
      observer.observe(el)
    })
  }
}
