import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Connects to data-controller="chat-subscription"
export default class extends Controller {
  static values = { chatId: Number }
  static targets = ["messages"]

  connect() {
    this.messagesTarget.lastElementChild?.scrollIntoView()

    const bookingActions = document.getElementById("booking_actions")
    if (bookingActions?.parentElement) {
      this.bookingObserver = new MutationObserver((mutations) => {
        mutations.forEach(mutation => {
          mutation.addedNodes.forEach(node => {
            if (node.id === "booking_actions") {
              node.scrollIntoView({ behavior: "smooth" })
            }
          })
        })
      })
      this.bookingObserver.observe(bookingActions.parentElement, { childList: true })
    }

    this.channel = createConsumer().subscriptions.create(
      { channel: "ChatChannel", id: this.chatIdValue },
      { received: data => {
        this.messagesTarget.insertAdjacentHTML("beforeend", data.trim())
        this.messagesTarget.lastElementChild?.scrollIntoView({ behavior: "smooth" })
      }}
    )
  }

  disconnect() {
    this.channel?.unsubscribe()
    this.bookingObserver?.disconnect()
  }
}
