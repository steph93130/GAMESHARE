import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "form", "button"]

  locate() {
    if (!navigator.geolocation) return

    this.buttonTarget.disabled = true
    this.buttonTarget.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>'

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords
        this.inputTarget.value = `${latitude},${longitude}`
        this.formTarget.submit()
      },
      () => {
        this.buttonTarget.disabled = false
        this.buttonTarget.innerHTML = '<i class="fa-solid fa-location-crosshairs"></i>'
      }
    )
  }
}
