import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl' // Don't forget this!

export default class extends Controller {
  static values = {
    apiKey: String,
    gameMarkers: Array,
    userMarkers: Array
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/celinedeshayes/cmq4xa07t002a01pfdllg1awt"

    })

    this.#addMarkersToMap()
    this.#fitMapToMarkers()
  }
  #addMarkersToMap() {
    this.gameMarkersValue.forEach((marker) => {
      const popup = new mapboxgl.Popup().setHTML(marker.info_window_html)
      const customGameMarker = document.createElement("div")
      customGameMarker.innerHTML = marker.marker_html
      new mapboxgl.Marker(customGameMarker)
        .setLngLat([marker.lng, marker.lat])
        .setPopup(popup)
        .addTo(this.map)
    })
    if (this.userMarkersValue) {
      this.userMarkersValue.forEach((marker) => {
        const customUserMarker = document.createElement("div")
        customUserMarker.innerHTML = marker.marker_html
        new mapboxgl.Marker(customUserMarker)
          .setLngLat([marker.lng, marker.lat])
          .addTo(this.map)
      })
    }
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds()
    this.gameMarkersValue.forEach(marker => bounds.extend([marker.lng, marker.lat]))
    if (this.userMarkersValue) {
      this.userMarkersValue.forEach(marker => bounds.extend([marker.lng, marker.lat]))
    }
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 3500 })
  }
}
