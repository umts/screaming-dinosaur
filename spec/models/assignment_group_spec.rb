# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignmentGroup do
  describe 'associations' do
    it { is_expected.to have_many(:assignments).dependent(:nullify) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
