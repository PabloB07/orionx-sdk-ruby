require "logger"

module OrionX
  class Logger
    attr_reader :logger

    def initialize(level: ::Logger::INFO, output: STDOUT)
      @logger = ::Logger.new(output)
      @logger.level = level
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity.ljust(5)} OrionX: #{msg}\n"
      end
    end

    def debug(message = nil, &block)
      if block_given?
        @logger.debug(&block)
      else
        @logger.debug(message)
      end
    end

    def info(message = nil, &block)
      if block_given?
        @logger.info(&block)
      else
        @logger.info(message)
      end
    end

    def warn(message = nil, &block)
      if block_given?
        @logger.warn(&block)
      else
        @logger.warn(message)
      end
    end

    def error(message = nil, &block)
      if block_given?
        @logger.error(&block)
      else
        @logger.error(message)
      end
    end

    def fatal(message = nil, &block)
      if block_given?
        @logger.fatal(&block)
      else
        @logger.fatal(message)
      end
    end

    def level=(level)
      @logger.level = level
    end

    def level
      @logger.level
    end
  end
end