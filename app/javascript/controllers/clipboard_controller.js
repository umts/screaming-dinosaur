import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['source', 'indicator'];
  static values = ['resetable'];

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.innerText).then(() => {
      this.indicatorTarget.animate({opacity: [100, 0]}, 150).finished.then(() => {
        this.indicatorTarget.setAttribute('class', 'fa-solid fa-check no-pointer-events');
        this.indicatorTarget.animate({opacity: [0, 100]}, 150);
        this.resetableValue = true;
      });
    }).catch(() => {
      this.indicatorTarget.animate({opacity: [100, 0]}, 150).finished.then(() => {
        this.indicatorTarget.setAttribute('class', 'fa-solid fa-xmark no-pointer-events');
        this.indicatorTarget.animate({opacity: [0, 100]}, 150);
        this.resetableValue = true;
      });
    });
  }
  connect() {
    console.log('connected');
  }

  reset() {
    if (this.resetableValue) {
      this.indicatorTarget.animate({opacity: [100, 0]}, 250).finished.then(() => {
        this.indicatorTarget.setAttribute('class', 'fa-regular fa-clipboard no-pointer-events');
        this.indicatorTarget.animate({opacity: [0, 100]}, 150);
        this.resetableValue = false;
      });
    }
  }
}
