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

    // Observe staggered sections if they exist
    const targets = [
      this.hasStaggerTarget ? this.staggerTarget : null,
      this.hasFaqTarget ? this.faqTarget : null,
      this.hasCtaTarget ? this.ctaTarget : null
    ].filter(Boolean)
    
    targets.forEach(target => {
      observer.observe(target)
    })
  }
}
