require 'optparse'
#require File.dirname(__FILE__) + '/../clarity'


module Clarity
  class CLI
    def self.execute(stdout, arguments=[])
      
      options = {
        :username => nil,
        :password => nil,
        :log_files => ['**/*.log*'],
        :port => 8080,
        :address => "0.0.0.0"
      }
      
      mandatory_options = %w(  )
      
      ARGV.options do |opts|
        opts.banner = "Usage:  #{File.basename($PROGRAM_NAME)} [options] directory"

        opts.separator " "
        opts.separator "Specific options:"

        opts.on( "-f", "--config=FILE", String, "Config file (yml)" ) do |opt|
          config = YAML.load_file( opt )
          config.keys.each do |key|
            options[key.to_sym] = config[key]
          end
        end

        opts.on( "-p", "--port=PORT", Integer, "Port to listen on" ) do |opt|
          options[:port] = opt
        end  

        opts.on( "-b", "--address=ADDRESS", String, "Address to bind to (default 0.0.0.0)" ) do |opt|
          options[:address] = opt
        end  

        opts.on( "--include=MASK", String, "File mask of logs to add (default: **/*.log*)" ) do |opt|
          options[:log_files] ||= []
          options[:log_files] += opt
        end

        opts.separator " "
        opts.separator "Password protection:"

        opts.on( "--username=USER", String, "Enable httpauth username" ) do |opt|
          options[:username] = opt
        end

        opts.on( "--password=PASS", String, "Enable httpauth password" ) do |opt|
          options[:password] = opt
        end

        opts.separator " "
        opts.separator "Misc:"

        opts.on( "-h", "--help", "Show this message." ) do
          puts opts
          exit
        end

        opts.separator " "

        begin
          opts.parse!(arguments)
          
          if arguments.first
            Dir.chdir(arguments.first)
          end
          
          ::Clarity::Server.run(options)
          
        #rescue
        #  puts opts
        #  exit
        end
      end
            
    end
  end
end