import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button", "line1", "line2"]

  connect() {
    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
      if (!this.element.contains(e.target) && this.isOpen) {
        this.close()
      }
    })

    // Close menu when screen size changes to desktop
    window.addEventListener('resize', () => {
      if (window.innerWidth >= 1024 && this.isOpen) {
        this.close()
      }
    })
  }

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.remove("h-0")
    this.menuTarget.classList.add("h-fit")
    this.buttonTarget.classList.add("active")
    this.line1Target.classList.add("rotate-45", "translate-y-[7px]")
    this.line2Target.classList.add("-rotate-45", "-translate-y-[7px]")
    this.isOpen = true
  }

  close() {
    this.menuTarget.classList.add("h-0")
    this.menuTarget.classList.remove("h-fit")
    this.buttonTarget.classList.remove("active")
    this.line1Target.classList.remove("rotate-45", "translate-y-[7px]")
    this.line2Target.classList.remove("-rotate-45", "-translate-y-[7px]")
    this.isOpen = false
  }

  get isOpen() {
    return this.data.get("open") === "true"
  }

  set isOpen(value) {
    this.data.set("open", value)
  }
}
