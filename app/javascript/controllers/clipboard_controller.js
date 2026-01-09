import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['source', 'indicator'];

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.innerText).then(() => {
      this.indicatorTarget.classList.remove('fa-clipboard');
      this.indicatorTarget.classList.add('fa-solid');
      this.indicatorTarget.classList.add('fa-check');
    }).catch(() => {
      this.indicatorTarget.classList.remove('fa-clipboard');
      this.indicatorTarget.classList.add('fa-solid');
      this.indicatorTarget.classList.add('fa-xmark');
    });
  }

  reset() {
    this.indicatorTarget.classList.remove('fa-check');
    this.indicatorTarget.classList.remove('fa-xmark');
    this.indicatorTarget.classList.remove('fa-solid');
    this.indicatorTarget.classList.add('fa-clipboard');
  }
}
