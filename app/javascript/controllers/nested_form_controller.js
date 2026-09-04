import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["template", "list"];

  add() {
    const uniqueId = Date.now();
    const content = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", uniqueId);

    this.listTarget.insertAdjacentHTML("beforeend", content);
  }

  remove(event) {
    event.target.closest('[data-nested-form-target="item"]').remove();
  }
}
