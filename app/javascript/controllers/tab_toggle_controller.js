import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["encours", "clotures", "btnEncours", "btnClotures"]

  connect() {
    this.showEncours()
  }

  showEncours() {
    this.encoursTarget.classList.remove("d-none")
    this.cloturesTarget.classList.add("d-none")
    this.btnEncoursTarget.classList.remove("button--inactive")
    this.btnCloturesTarget.classList.add("button--inactive")
  }

  showClotures() {
    this.encoursTarget.classList.add("d-none")
    this.cloturesTarget.classList.remove("d-none")
    this.btnCloturesTarget.classList.remove("button--inactive")
    this.btnEncoursTarget.classList.add("button--inactive")
  }
}
