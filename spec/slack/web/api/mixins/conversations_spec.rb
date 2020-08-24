# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Slack::Web::Api::Mixins::Conversations do
  subject(:conversations) do
    klass.new
  end

  let(:klass) do
    Class.new do
      include Slack::Web::Api::Mixins::Conversations

      def conversations_list
        Slack::Messages::Message.new(
          'channels' => [{
            'id' => 'CDEADBEEF',
            'name' => 'general'
          }]
        )
      end
    end
  end

  describe '#conversations_id' do
    it 'leaves channels specified by ID alone' do
      expect(conversations.conversations_id(channel: 'C123456')).to(
        eq('ok' => true, 'channel' => { 'id' => 'C123456' })
      )
    end
    it 'translates a channel that starts with a #' do
      expect(conversations.conversations_id(channel: '#general')).to(
        eq('ok' => true, 'channel' => { 'id' => 'CDEADBEEF' })
      )
    end
    it 'fails with an exception' do
      expect { conversations.conversations_id(channel: '#invalid') }.to(
        raise_error(Slack::Web::Api::Errors::SlackError, 'channel_not_found')
      )
    end

    context 'with pagination' do
      let(:klass) do
        Class.new do
          include Slack::Web::Api::Endpoints::Conversations
          include Slack::Web::Api::Mixins::Conversations

          def default_max_retries
            0
          end

          def default_page_size
            1
          end

          def post(_, options = {})
            if options[:cursor] == 'xyz'
              return Slack::Messages::Message.new(
                'channels' => [{
                  'id' => 'CDEADBEEF',
                  'name' => 'random'
                }],
                'response_metadata' => {
                  'next_cursor' => 'xyz'
                }
              )
            end

            Slack::Messages::Message.new(
              'channels' => [{
                'id' => 'CDEADBEEF',
                'name' => 'general'
              }]
            )
          end
        end
      end

      it 'translates a channel that starts with a #' do
        expect(conversations.conversations_id(channel: '#general')).to(
          eq('ok' => true, 'channel' => { 'id' => 'CDEADBEEF' })
        )
      end
    end
  end
end
