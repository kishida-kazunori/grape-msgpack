require 'msgpack'
require 'grape'
require 'grape/msgpack/version'

module Grape
  # Message pack formatter for Grape
  module Msgpack
    module Formatter
      class << self
        def call(obj, env)
          return obj.to_msgpack if obj.respond_to?(:to_msgpack)
          MessagePack.pack(obj)
        end
      end
    end

    module ErrorFormatter

      class << self
        include Grape::ErrorFormatter::Base

        def call(message, backtrace, options = {}, env = nil, original_exception = nil)

          result = wrap_message(present(message, env))

          rescue_options = options[:rescue_options] || {}
          if rescue_options[:backtrace] && backtrace && !backtrace.empty?
            result = result.merge(backtrace: backtrace)
          end
          if rescue_options[:original_exception] && original_exception
            result = result.merge(original_exception: original_exception.inspect)
          end
          MessagePack.pack(result)
        end

        private

          def wrap_message(message)
            if message.is_a?(Exceptions::ValidationErrors) || message.is_a?(Hash)
              message
            else
              { error: message }
            end
          end
      end
    end

    module Parser
      class << self
        def call(object, env)
          MessagePack.unpack(object)
        end
      end
    end
  end
end

Grape::Formatter.register(:msgpack, Grape::Msgpack::Formatter)
Grape::ErrorFormatter.register(:msgpack, Grape::Msgpack::ErrorFormatter)
Grape::Parser.register(:msgpack, Grape::Msgpack::Parser)

if defined?(Grape::Entity)
  class Grape::Entity
    def to_msgpack(pack = nil)
      if pack
        pack.write(serializable_hash)
      else
        MessagePack.pack(serializable_hash)
      end
    end
  end
end
