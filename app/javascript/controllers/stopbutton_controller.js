import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="stopbutton"
export default class extends Controller {
  static targets = ["input", "button"]

  connect() {
    this.#update()
  }

  update() {
    this.#update()
  }

  #update() {
    this.buttonTarget.disabled = this.inputTarget.value.trim() === ""
  }
}
