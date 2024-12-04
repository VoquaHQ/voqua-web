import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.dismissId = this.element.dataset.dismiss;
    this.btn = this.element.querySelector('[data-action="dismiss"]');
    this.onClick = this.onClick.bind(this);
    this.btn.addEventListener("click", this.onClick);

    const dismissed = localStorage.getItem(`${this.dismissId}-dismissed`);
    if (dismissed === "true") {
      this.element.remove();
      return;
    }
  }

  disconnect() {
    this.btn.removeEventListener("click", this.onClick);
  }

  onClick() {
    localStorage.setItem(`${this.dismissId}-dismissed`, "true");
    this.element.remove();
  }
}
