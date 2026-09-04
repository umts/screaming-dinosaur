import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["source", "promptIndicator", "successIndicator", "errorIndicator"];

  copy() {
    navigator.clipboard
      .writeText(this.sourceTarget.innerText)
      .then(() => {
        this.#hideIndicators();
        for (const target of this.successIndicatorTargets) target.hidden = false;
        return null;
      })
      .catch(() => {
        this.#hideIndicators();
        for (const target of this.errorIndicatorTargets) target.hidden = false;
      });
  }

  reset() {
    this.#hideIndicators();
    for (const target of this.promptIndicatorTarget) target.hidden = false;
  }

  #hideIndicators() {
    for (const target of [
      ...this.promptIndicatorTargets,
      ...this.successIndicatorTargets,
      ...this.errorIndicatorTargets,
    ]) {
      target.hidden = true;
    }
  }
}
