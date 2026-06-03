import { Controller } from "@hotwired/stimulus"


// Connects to data-controller="stopbutton"
export default class extends Controller {

  static targets = ["input", "button"]

  call() {
    if (this.inputTarget.value !== ''){
      this.buttonTarget.classList.remove("disabled")
    } else if ((this.inputTarget.value === '')) {
      this.buttonTarget.classList.add("disabled")
    } else {
      this.buttonTarget.classList.add("disabled")
    }
  }
}

