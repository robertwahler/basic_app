require 'term/ansicolor'

class String
  include Term::ANSIColor
end

module BasicApp

  AVAILABLE_ACTIONS = %w[help list task]

  class App
    include BasicApp::Os

    # bin wrapper option parser object
    attr_accessor :option_parser

    def initialize(argv=[], configuration={})
      @configuration = configuration.deep_clone
      @options = @configuration[:options] || {}
      @argv = argv.dup
      $stdout.sync = true

      if STDOUT.isatty || (@options[:color] == 'ALWAYS')
        Term::ANSIColor::coloring = @options[:color]

        if @options[:color] && windows?
          unless ENV['ANSICON']
            begin
              require 'Win32/Console/ANSI'
            rescue LoadError
              Term::ANSIColor::coloring = false
              STDERR.puts 'WARNING: You must "gem install win32console" (1.2.0 or higher) or use the ANSICON driver (https://github.com/adoxa/ansicon) to get color output on MRI/Windows'
            end
          end
        end

      else
        Term::ANSIColor::coloring = false
      end

      config_filename = @configuration[:configuration_filename]
      BasicApp::Logger::Manager.new(config_filename, :logging, @configuration)

      logger.debug "configuration: #{@configuration.inspect}"
      logger.debug "argv: #{@argv.inspect}"
      logger.debug "config file: #{@configuration[:configuration_filename]}" if @configuration[:configuration_filename]
    end

    def execute
      begin

        args = @argv
        if action_argument_required?
          action = @argv.shift

          # special case: actionless tasks
          action = 'task' if action.nil? && @options.include?(:tasks)

          # special case: `basic_app sweep:screenshots` is an acceptable task action
          if action && action.match(/[a-zA-Z]+:+/)
            args.unshift(action)
            action = 'task'
          end

          # special case: `basic_app help sweep:screenshots` is an acceptable task help action
          if action == 'help' && args.any?
            target = args[0]
            if target.match(/[a-zA-Z]+:+/)
              args.unshift(action)
              action = 'task'
            end
          end

          unless AVAILABLE_ACTIONS.include?(action)
            if action.nil?
              puts "basic_app action required"
            else
              puts "basic_app invalid action: #{action}"
            end
            puts "basic_app --help for more information"
            exit 1
          end
          logger.debug "execute action: #{action} #{args.join(' ')}"
          klass = Object.const_get('BasicApp').const_get("#{action.capitalize}Action")
          app_action = klass.new(args, @configuration)
          app_action.option_parser = self.option_parser
          result = app_action.execute
        else
          #
          # default action if action_argument_required? is false
          #
          result = 0
        end

        if result.is_a?(Numeric)
          exit(result)
        else
          # handle all other return types
          exit(result ? 0 : 1)
        end

      rescue SystemExit => e
        # This is the normal exit point
        logger.debug "basic_app run system exit: #{e}, status code: #{e.status}"
        exit(e.status)
      rescue Exception => e
        logger.fatal("basic_app fatal exception: #{e.message}")
        STDERR.puts("basic_app failed: #{e.message}".red)
        STDERR.puts("Command failed, use '--verbose' for backtrace.") unless @options[:verbose]
        STDERR.puts(e.backtrace.join("\n")) if @options[:verbose]
        exit(1)
      end
    end

  private

    # true if application requires an action to be specified on the command line
    def action_argument_required?
      !AVAILABLE_ACTIONS.empty?
    end

  end
end
