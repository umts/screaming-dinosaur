
import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['template', 'list'];

  add() {
    const uniqueId = new Date().getTime();
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, uniqueId);

    this.listTarget.insertAdjacentHTML('beforeend', content);
  }

  remove(event) {
    event.target.closest('[data-nested-form-target="item"]').remove();
  }
}
