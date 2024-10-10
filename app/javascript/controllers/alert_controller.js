import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.btn = document.querySelector(".close", this.element);
    this.onClick = this.onClick.bind(this);
    this.btn.addEventListener("click", this.onClick);
  }

  disconnect() {
    this.btn.removeEventListener("click", this.onClick);
  }

  onClick() {
    this.element.remove();
  }
}
