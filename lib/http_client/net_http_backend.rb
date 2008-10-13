module HttpClient
  class NullListener
    def self.noop(*method_names)
      method_names.each do |method_name|
        define_method(method_name){}
      end
    end

    noop :handle_initiate, :handle_open, :handle_close
  end

  class NetHttpBackend
    def self.open(host, options = {})
      self.new(host, options)
    end

    def initialize(host, options)
      @listener   = options.fetch(:listener){NullListener.new}
      @listener.handle_initiate
      @connection = Net::HTTP.start(host, 80)
      @listener.handle_open
    end

    def close!
      @connection.finish
      @listener.handle_close
    end
  end
end
