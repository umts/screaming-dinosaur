import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['source', 'promptIndicator', 'successIndicator', 'errorIndicator'];

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.innerText).then(() => {
      this.#hideIndicators();
      this.successIndicatorTargets.forEach((target) => target.hidden = false);
    }).catch(() => {
      this.#hideIndicators();
      this.errorIndicatorTargets.forEach((target) => target.hidden = false);
    });
  }

  reset() {
    this.#hideIndicators();
    this.promptIndicatorTargets.forEach((target) => target.hidden = false);
  }

  #hideIndicators() {
    [
      ...this.promptIndicatorTargets,
      ...this.successIndicatorTargets,
      ...this.errorIndicatorTargets,
    ].forEach((target) => {
      target.hidden = true;
    });
  }
}
