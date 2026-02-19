# frozen_string_literal: true

module Maintenance
  RSpec.describe RemoveMembershipsFromInactiveUsersTask do
    describe '#process' do
      subject(:process) { described_class.process(element) }
      let(:element) do
        # Object to be processed in a single iteration of this task
      end

      pending "add some examples to (or delete) #{__FILE__}"
    end
  end
end
