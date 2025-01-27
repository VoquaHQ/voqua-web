import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nav", "logo", "menu", "support"]

  connect() {
    this.onScroll()
  }

  onScroll() {
    const isScrolled = window.scrollY > 10
    const isMobile = window.innerWidth < 640
    
    if (isScrolled) {
      this.navTarget.classList.add('bg-white/95', 'shadow-sm')
      // Mobile-specific animations
      if (isMobile) {
        this.logoTarget.classList.add('w-0', 'opacity-0', 'invisible')
        this.menuTarget.classList.add('-translate-x-8')
        // Show support link with slight delay
        setTimeout(() => {
          this.supportTarget.classList.remove('hidden')
          this.supportTarget.classList.add('flex')
        }, 150)
      }
    } else {
      this.navTarget.classList.remove('bg-white/95', 'shadow-sm')
      if (isMobile) {
        this.logoTarget.classList.remove('w-0', 'opacity-0', 'invisible')
        this.menuTarget.classList.remove('-translate-x-8')
        // Hide support link immediately
        this.supportTarget.classList.remove('flex')
        this.supportTarget.classList.add('hidden')
      }
    }
  }
}
