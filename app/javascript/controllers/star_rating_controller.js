import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "label", "submit", "starsList"]

  labels = ["", "Bof... 😕", "Pas terrible 😐", "Correct 🙂", "Très bien 😊", "Parfait ! 🌟"]
  currentScore = 0

  hover(event) {
    const value = parseInt(event.currentTarget.dataset.value)
    this.highlightStars(value)
    this.labelTarget.textContent = this.labels[value]
  }

  resetHover() {
    this.highlightStars(this.currentScore)
    this.labelTarget.textContent = this.currentScore === 0
      ? "Clique sur une étoile pour noter"
      : this.labels[this.currentScore]
  }

  select(event) {
    this.currentScore = parseInt(event.currentTarget.dataset.value)
    this.inputTarget.value = this.currentScore
    this.highlightStars(this.currentScore)
    this.submitTarget.disabled = false
    this.labelTarget.textContent = this.labels[this.currentScore]

    this.starsListTarget.querySelectorAll(".star-item").forEach((star, i) => {
      star.classList.toggle("star-confirmed", i < this.currentScore)
    })
  }

  skip() {
    const container = document.getElementById("rating_modal_container")
    if (container) container.remove()
  }

  highlightStars(count) {
    this.starsListTarget.querySelectorAll(".star-item").forEach((star, i) => {
      const icon = star.querySelector("i")
      const active = i < count
      icon.classList.toggle("fa-solid", active)
      icon.classList.toggle("fa-regular", !active)
      star.classList.toggle("star-active", active)
    })
  }
}
