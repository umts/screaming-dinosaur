# frozen_string_literal: true

RSpec.describe 'Twilio' do
  let(:roster) { create :roster }
  let(:user) { create :user, rosters: [roster], phone: '(413) 545-0056' }

  before { create :assignment, start_date: Date.yesterday, end_date: Date.tomorrow, roster:, user: }

  describe 'GET /rosters/:roster_id/twilio/call.xml' do
    let(:call) { get "/rosters/#{roster.slug}/twilio/call", headers: { 'ACCEPT' => 'application/xml' } }

    it 'responds successfully' do
      call
      expect(response).to be_successful
    end

    it 'responds with a twilio directive to call the on call user' do
      call
      expect(response.body).to eq(<<~XML)
        <?xml version='1.0' encoding='utf-8' ?>
        <Response>
        <Dial>+14135450056</Dial>
        </Response>
      XML
    end
  end

  describe 'GET /rosters/:roster_id/twilio/text.xml' do
    let(:call) do
      get "/rosters/#{roster.slug}/twilio/text",
          headers: { 'ACCEPT' => 'application/xml' },
          params: { 'Body' => 'IMPORTANT MESSAGE' }
    end

    it 'responds successfully' do
      call
      expect(response).to be_successful
    end

    it 'responds with a twilio directive to text the on call user' do
      call
      expect(response.body).to eq(<<~XML)
        <?xml version='1.0' encoding='utf-8' ?>
        <Response>
        <Message to="+14135450056">IMPORTANT MESSAGE</Message>
        </Response>
      XML
    end
  end
end
