# frozen_string_literal: true
require_relative 'ids.id'

module Slack
  module Web
    module Api
      module Mixins
        module Conversations
          #
          # This method returns a channel ID given a channel name.
          #
          # @option options [channel] :channel
          #   Channel to get ID for, prefixed with #.
          def conversations_id(options = {})
            name = options[:channel]
            throw ArgumentError.new('Required arguments :channel missing') if name.nil?

            return { 'ok' => true, 'channel' => { 'id' => name } } unless name[0] == '#'

            conversations_list do |page|
              page.channels.each do |channel|
                if channel.name == name[1..-1]
                  return Slack::Messages::Message.new('ok' => true, 'channel' => { 'id' => channel.id })
                end
              end
            end

            raise Slack::Web::Api::Errors::SlackError, 'channel_not_found'
          end
        end
      end
    end
  end
end
