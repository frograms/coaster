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
        raise "Error executing command\nPATH: #{path}\nCMD: #{command}\nSTDERR:\n  ↳ #{stderr.split("\n").join("\n    ")}\nSTDOUT:\n  ↳ #{stdout.split("\n").join("\n    ")}"
      end
    end

    def options_to_s(options)
      case options
      when Hash then options_h_to_s(options)
      when Array, Set then options.map{|o| options_to_s(o)}.join(' ')
      else options
      end
    end

    def options_h_merger(options, base: {})
      base = base.map do |k, v|
        if !v.is_a?(Array) && !v.is_a?(Set)
          [k, [v]]
        else
          [k, v]
        end
      end.to_h
      options.each do |k, v|
        if base.key?(k)
          base[k] << v
        else
          base[k] = [v]
        end
      end
      base
    end

    OPTION_ALIAS = {
      '-m' => '--message',
    }

    def options_h_alias_merger(options)
      OPTION_ALIAS.each do |k, v|
        if options[k].present?
          options[v] = options.delete(k)
        end
      end
      options
    end

    def options_s_to_h(options)
      opts = {}
      options = " #{options}"
      options_indexes = options.enum_for(:scan, / -\w| --\w+| -- /).map { Regexp.last_match.begin(0) }
      options_indexes << 0
      options_indexes.each_cons(2) do |a, b|
        option = options[a+1..b-1]
        h = option_s_to_h(option)
        options_h_merger(h, base: opts)
      end
      opts
    end

    def option_s_to_h(option)
      if option.start_with?(/--\w/)
        opt = option.split('=', 2)
        opt << '' if opt.length == 1
      elsif option.start_with?(/-\w/)
        opt = option.split(' ', 2)
        opt << '' if opt.length == 1
      elsif option.start_with?('-- ')
        opt = ['--', option[3..-1].split(' ')]
      else
        return {}
      end
      opt[1] = opt[1].split(',') if opt[1].include?(',')
      opt[1] = opt[1].map{|s| s.include?('=') ? Hash[s.split('=', 2)] : s}.to_h if opt[1].is_a?(Array)
      [opt].to_h
    end

    def option_v_to_s(option_v)
      case option_v
      when Hash then option_v.map{|vk,vv| "#{vk}=#{vv}"}.join(',')
      when Array, Set then option_v.map{|v| option_v_to_s(v)}.join(',')
      else option_v || ''
      end
    end

    def options_h_to_s(options)
      opts = []

      # multiple options can be passed by set
      options.map do |k, v|
        if v.is_a?(Set)
          v.each {|set_v| opts << [k, set_v]}
        else
          opts << [k, v]
        end
      end

      targets = ''
      parsed = opts.map do |k, v|
        if k.start_with?(/--\w/)
          v = option_v_to_s(v)
          "#{k}#{v.length > 0 ? "=#{v}" : ''}" # ex, --config-env=<name>=<envvar>
        elsif k.start_with?(/-\w/)
          v = option_v_to_s(v)
          "#{k} #{v.length > 0 ? "#{v}" : ''}" # ex, -c <name>=<value>
        elsif k == '--'
          v = v.join(' ') if v.is_a?(Array)
          targets = "#{k} #{v}" # ex, -- <args>
          ''
        else
          raise "Unknown option: #{k}"
        end
      end
      parsed << targets
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
