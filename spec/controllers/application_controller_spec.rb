# frozen_string_literal: true

RSpec.describe ApplicationController do
  describe '.api_accessible' do
    controller do
      api_accessible
      def index
        render(plain: 'OHAI')
      end
    end

    subject(:submit) { get :index, params: params }

    let(:params) { {} }

    context 'with a valid API key' do
      let(:params) { { api_key: 'bananas' } }

      before do
        allow(Rails.application).to receive(:credentials).and_return({ api_key: 'bananas' })
        submit
      end

      it 'allows you in' do
        expect(response.body).to eq 'OHAI'
      end
    end

    context 'with a valid user' do
      before do
        when_current_user_is :anyone
        submit
      end

      it 'allows you in' do
        expect(response.body).to eq 'OHAI'
      end
    end

    context 'with neither a valid API key nor user session' do
      before { submit }

      it "doesn't allow you in" do
        expect(response).to redirect_to(unauthenticated_session_path)
      end
    end
  end
end

