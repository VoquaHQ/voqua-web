import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    interval: { type: Number, default: 300 },
  };

  connect() {
    this.visible = true;
    this.startFlashing();
  }

  disconnect() {
    this.stopFlashing();
  }

  startFlashing() {
    this.flashingInterval = setInterval(() => {
      this.visible = !this.visible;
      this.element.classList.toggle("opacity-30", !this.visible);
      this.element.classList.toggle("opacity-100", this.visible);
    }, this.intervalValue);
  }

  stopFlashing() {
    if (this.flashingInterval) {
      clearInterval(this.flashingInterval);
    }
  }
}
