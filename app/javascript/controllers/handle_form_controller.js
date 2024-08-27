import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  initialize() {
    this.field = document.querySelector("input[name='handle']", this.element);
    this.btn = document.querySelector("button[type='submit']", this.element);

    this.onChange = this.onChange.bind(this);
  }

  connect() {
    this.field.addEventListener("change", this.onChange);
    this.field.addEventListener("keyup", this.onChange);
  }

  disconnect() {
    this.field.removeEventListener("change", this.onChange);
    this.field.removeEventListener("keyup", this.onChange);
  }

  onChange() {
    if (this.field.value.trim().length > 0) {
      this.btn.disabled = false;
    } else {
      this.btn.disabled = true;
    }
  }
}
