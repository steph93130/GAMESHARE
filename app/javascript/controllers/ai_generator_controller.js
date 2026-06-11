import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "button", "label", "icon", "spinner", "alert",
    "title", "image", "description", "rules", "preview", "previewWrapper", "editButton"
  ]

  async generate() {
    const url = this.element.dataset.aiGeneratorUrlValue
  console.log("URL:", url) // <-- Vérifiez dans la console du navigateur
  
  if (!url) {
    console.error("URL is null! Check data-ai-generator-url-value attribute")
    this.alertTarget.textContent = "Configuration manquante"
    this.alertTarget.classList.remove("d-none")
    return
  }

  const title = this.titleTarget.value.trim()
  const imageInput = this.imageTarget
  const csrfToken = document.querySelector('meta[name="csrf-token"]').content

  this.alertTarget.classList.add("d-none")

  if (!title) {
    this.alertTarget.textContent = "Veuillez d'abord renseigner le titre du jeu."
    this.alertTarget.classList.remove("d-none")
    return
  }

  this.buttonTarget.disabled = true
  this.iconTarget.classList.add("d-none")
  this.spinnerTarget.classList.remove("d-none")
  this.labelTarget.textContent = "Génération en cours…"

  try {
    const body = new FormData()
    body.append("title", title)
    if (imageInput && imageInput.files[0]) {
      body.append("image", imageInput.files[0])
    }

    const response = await fetch(this.data.get("url"), {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json"
      },
      body,
      credentials: 'include'
    })

    const data = await response.json()

    if (!response.ok || data.error) {
      throw new Error(data.error || "Erreur serveur")
    }

    if (data.description) this.descriptionTarget.value = data.description
    if (data.rules) {
      this.rulesTarget.value = data.rules
      this.previewTarget.innerHTML = data.rules
      this.showPreview()
    }

  } catch (err) {
    this.alertTarget.textContent = "Erreur : " + err.message
    this.alertTarget.classList.remove("d-none")
  } finally {
    this.buttonTarget.disabled = false
    this.iconTarget.classList.remove("d-none")
    this.spinnerTarget.classList.add("d-none")
    this.labelTarget.textContent = "Générer la description et les règles via l'IA"
  }
}

  showPreview() {
    this.rulesTarget.classList.add("d-none")
    this.previewWrapperTarget.classList.remove("d-none")
    this.editButtonTarget.classList.remove("d-none")
  }

  showTextarea() {
    this.previewWrapperTarget.classList.add("d-none")
    this.rulesTarget.classList.remove("d-none")
    this.editButtonTarget.classList.add("d-none")
  }
}