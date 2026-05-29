import {Controller} from '@hotwired/stimulus';
import TomSelect from 'tom-select';

export default class extends Controller {
  connect() {
    this.tomSelect = new TomSelect(this.element, this.#tomSelectOptions());
  }

  #tomSelectOptions() {
    const options = {
      create: false,
      plugins: [],
      refreshThrottle: 0,
      allowEmptyOption: true,
      render: {
        option: (data, escape) => `<div>${escape(data.text || '\u00A0')}</div>`,
      },
    };
    if (this.element.multiple) {
      options.plugins.push('clear_button');
    }
    if (this.element.dataset.search) {
      options.plugins.push('dropdown_input');

      if (!(this.element.dataset.truncate)) {
        options.maxOptions = null;
      }
    } else {
      options.controlInput = null;
      options.maxOptions = null;
    }
    return options;
  }
}
