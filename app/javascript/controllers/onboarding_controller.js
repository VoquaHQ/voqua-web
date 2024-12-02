import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "guide"]
  static values = {
    currentStep: Number,
    hasSeenGuide: Boolean
  }

  connect() {
    if (localStorage.getItem('hasSeenQuadraticVotingGuide')) {
      this.guide.classList.add('hidden')
      return
    }

    this.currentStepValue = 0
    this.showCurrentStep()
  }

  next() {
    if (this.currentStepValue < this.stepTargets.length - 1) {
      this.currentStepValue++
      this.showCurrentStep()
    } else {
      this.completeGuide()
    }
  }

  previous() {
    if (this.currentStepValue > 0) {
      this.currentStepValue--
      this.showCurrentStep()
    }
  }

  showCurrentStep() {
    this.stepTargets.forEach((step, index) => {
      if (index === this.currentStepValue) {
        step.classList.remove('hidden')
      } else {
        step.classList.add('hidden')
      }
    })
  }

  completeGuide() {
    localStorage.setItem('hasSeenQuadraticVotingGuide', 'true')
    this.guide.classList.add('hidden')
  }

  get guide() {
    return this.guideTarget
  }
}
