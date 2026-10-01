import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["template", "append"];

  append() {
    const index = Date.now();
    const content = this.templateTarget.innerHTML.replaceAll("INDEX", index);
    this.appendTarget.insertAdjacentHTML("beforeend", content);
  }
}
