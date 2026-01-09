import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['source', 'indicator'];

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.innerText).then(() => {
      // TODO: Change indicator to checkmark.
    }).catch(() => {
      // TODO: Change indicator to x mark.
    });
  }

  reset() {
    // TODO: Change indicator to clipboard.
  }
}
