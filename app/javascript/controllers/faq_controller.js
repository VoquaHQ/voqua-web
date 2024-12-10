import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("FAQ controller connected")
    
    // Initialize all answers with transition styles
    document.querySelectorAll('.faq-answer').forEach(answer => {
      answer.style.transition = 'all 0.3s ease-out'
      answer.style.maxHeight = '0'
      answer.style.opacity = '0'
      answer.style.overflow = 'hidden'
    })
  }

  toggle(event) {
    console.log("Toggle clicked")
    
    // Get the parent FAQ item
    const item = event.currentTarget.closest('.faq-item')
    const answer = item.querySelector('.faq-answer')
    const icon = item.querySelector('.faq-icon')
    
    // Toggle the answer
    if (answer.style.maxHeight === '0px' || !answer.style.maxHeight) {
      answer.classList.remove('hidden')
      answer.style.maxHeight = answer.scrollHeight + 'px'
      answer.style.opacity = '1'
      icon.style.transform = 'rotate(180deg)'
    } else {
      answer.style.maxHeight = '0'
      answer.style.opacity = '0'
      icon.style.transform = 'rotate(0)'
      // Add hidden class after transition
      setTimeout(() => {
        if (answer.style.maxHeight === '0px') {
          answer.classList.add('hidden')
        }
      }, 300)
    }
  }
}
