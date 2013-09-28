require 'optparse'

module Taketo

  class CLI
    DEFAULT_CONFIG_FILE = File.join(ENV['HOME'], ".taketo.rc.rb")

    def initialize(argv)
      @argv = argv.dup
      @options = parse_options!
    end

    def run
      trap_sigint!
      action = Actions[@options[:action]].new(@options)
      action.run
    rescue SystemExit
      # Do nothing
    rescue Exception => e
      warn "An error occurred: #{e.message}"
      if @options && @options[:debug]
        warn e.backtrace
        raise
      end
      exit 1
    end

    def parse_options!
      options = { :config => DEFAULT_CONFIG_FILE, :action => :login }

      OptionParser.new do |opts|
        opts.banner = "Usage: taketo [destination] [options]"
        opts.version = VERSION

        opts.separator ""
        opts.separator "Common options:"

        opts.on("-f CONFIG", "--config", "Use custom config file (default: #{DEFAULT_CONFIG_FILE})") { |v| options[:config] = v }
        opts.on("-c COMMAND", "--command", "Command to execute on destination server",
                "  (COMMAND either declared in config or passed as an argument)")                    { |v| options[:command] = v }
        opts.on("-d DIRECTORY", "--directory", "Directory on destination server to cd to")           { |v| options[:directory] = v }
        opts.on("-v", "--view", "Show config contents and exit")                                     { |v| options[:action] = :view; options[:view] = true }
        opts.on("--generate-ssh-config", "Generate SSH config from taketo config")                   { |v| options[:action] = :generate_ssh_config }
        opts.on("--list", "List servers in given group")                                             { |v| options[:action] = :list; options[:list] = true }

        opts.separator "Special options:"

        opts.on("--dry-run", "Print out what would be run") { |v| options[:dry_run] = v }
        opts.on("--matches")                                { |v| options[:action] = :matches }
        opts.on("--edit-config")                            { |v| options[:action] = :edit_config }
        opts.on("--debug")                                  { |v| options[:debug] = v }
      end.parse!(@argv)

      options.merge!(:destination_path => @argv.shift.to_s)
    end
    private :parse_options!

    def trap_sigint!
      Signal.trap("SIGINT") do
        puts "Terminating"
        exit 1
      end
    end
    private :trap_sigint!
  end

end

