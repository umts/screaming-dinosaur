# frozen_string_literal: true

RSpec.describe TwilioController do
  subject(:xml) do
    call
    Nokogiri::XML response.body
  end

  let(:roster) { create :roster }
  let(:user) { roster_user(roster) }
  let(:user_phone) { Phonelib.parse(user.phone).full_e164 }

  before do
    create :assignment, start_date: Date.yesterday, end_date: Date.tomorrow, roster:, user:
  end

  describe 'GET /rosters/:id/twilio/call.xml' do
    let(:call) { get "/rosters/#{roster.id}/twilio/call.xml" }

    it 'has a "Response" root element' do
      expect(xml.root.name).to eq('Response')
    end

    it 'calls the correct user' do
      expect(xml.at_xpath('/Response/Dial').text).to eq(user_phone)
    end
  end

  describe 'GET /rosters/:id/twilio/text.xml' do
    let(:call) do
      get "/rosters/#{roster.id}/twilio/text.xml", params: { 'Body' => 'IMPORTANT MESSAGE' }
    end

    it 'has a "Response" root element' do
      expect(xml.root.name).to eq('Response')
    end

    it 'messages the correct user' do
      expect(xml.at_xpath("/Response/Message[@to='#{user_phone}']")).to be_present
    end

    it 'forwards the message' do
      expect(xml.at_xpath("/Response/Message[@to='#{user_phone}']").text).to eq('IMPORTANT MESSAGE')
    end
  end
end
