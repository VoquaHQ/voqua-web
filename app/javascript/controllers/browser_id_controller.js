import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    let browserId = localStorage.getItem('voqua_browser_id')
    if (!browserId) {
      browserId = this.generateUUID()
      localStorage.setItem('voqua_browser_id', browserId)
    }
    if (this.hasInputTarget) {
      this.inputTarget.value = browserId
    }
  }

  generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8)
      return v.toString(16)
    })
  }
}
