# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Current do
  describe '.reset' do
    it 'does not set the PaperTrail whodunnit when the request has versioning disabled' do
      PaperTrail.request(enabled: false) do
        described_class.user = create(:user)
        expect { described_class.reset }.not_to raise_error
      end
    end
  end
end
