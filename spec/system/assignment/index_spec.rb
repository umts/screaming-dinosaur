# frozen_string_literal: true

require 'spec_helper'

describe 'user pages', js:true do
  let(:membership) { create :membership, admin: true }
  let(:admin) { create :user, memberships: [membership] }

  context 'copying ics url' do
    before :each do
      set_current_user(admin)
      visit root_url
    end
    it 'displays copy url info' do
      find('.glyphicon-info-sign').click.hover
      expect(page).to have_selector '.tooltip', text: 'Use this address to subscribe'
    end
    it 'displays click to copy tooltip' do
      find('.copy-text-btn').hover
      expect(page).to have_selector '.tooltip', text: 'Click to copy link'
    end
    it 'copys link on button press' do
      find('.copy-text-btn').click.hover
      expect(page).to have_selector '.tooltip', text: 'Copied successfully!'
    end
  end
end
