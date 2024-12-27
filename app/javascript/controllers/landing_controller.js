import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fadeIn", "stagger", "faq", "cta"]

  connect() {
    // Initial animations
    this.fadeInTarget.setAttribute("data-show", "true")
    
    // Setup intersection observer for other sections
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.setAttribute("data-show", "true")
          observer.unobserve(entry.target)
        }
      })
    }, {
      threshold: 0.1
    })

    // Observe staggered sections
    ;[this.staggerTarget, this.faqTarget, this.ctaTarget].forEach(target => {
      observer.observe(target)
    })
  }
}
