require 'open3'

module Coaster
  module Git
    def run_cmd(path, command)
      puts "#{path}: #{command}"
      stdout, stderr, status = Open3.capture3(command, chdir: path)
      if status.success?
        puts "  ↳ success: #{stdout.split("\n").join("\n             ")}"
        stdout
      else
        raise "Error executing command: #{command}\n  ↳ #{stderr.split("\n").join("\n    ")}"
      end
    end

    def option_parser(options)
      case options
      when Hash then hash_option_parser(options)
      when Array, Set then options.map{|o| option_parser(o)}.join(' ')
      else options
      end
    end

    def hash_option_parser(options)
      opts = []

      # multiple options can be passed by set
      options.map do |k, v|
        if v.is_a?(Set)
          v.each {|set_v| opts << [k, set_v]}
        else
          opts << [k, v]
        end
      end

      parsed = opts.map do |k, v|
        v = case v
        when Hash then v.map{|vk,vv| "#{vk}=#{vv}"}.join(',')
        when Array then v.join(',')
        else v || ''
        end
        v = v.strip
        if k.start_with?('--')
          "#{k}#{v.length > 0 ? "=#{v}" : ''}" # ex, --config-env=<name>=<envvar>
        else
          "#{k} #{v.length > 0 ? "#{v}" : ''}" # ex, -c <name>=<value>
        end
      end

      parsed.join(' ')
    end

    class << self
      include Coaster::Git

      def create(path)
        run_cmd(path.split('/')[0..-2].join('/'), "git init #{path}")
        run_cmd(path, "git commit --allow-empty -m 'initial commit'")
        Repository.new(path)
      end
    end
  end
end

require 'coaster/git/repository'
