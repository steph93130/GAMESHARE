import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Connects to data-controller="chat-subscription"
export default class extends Controller {
  static values = { chatId: Number }
  static targets = ["messages"]

  connect() {
    this.messagesTarget.scrollTo(0, this.messagesTarget.scrollHeight)
    this.channel = createConsumer().subscriptions.create(
      { channel: "ChatChannel", id: this.chatIdValue },
      { received: data => {
        this.messagesTarget.insertAdjacentHTML("beforeend", data.trim())
        this.messagesTarget.scrollTo(0, this.messagesTarget.scrollHeight)
      }}
    )
  }

  disconnect() {
    this.channel?.unsubscribe()
  }
}
