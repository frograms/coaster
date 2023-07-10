require 'optparse'

module Coaster
  class CmdOptions
    class << self
      def options_to_s(options)
        case options
        when Hash then options_h_to_s(options)
        when Array, Set then options.map{|o| options_to_s(o)}.join(' ')
        else options
        end
      end

      def option_v_to_s(option_v)
        case option_v
        when Hash then option_v.map{|vk,vv| Set[vk, vv]}.to_set
        when Array then option_v.map{|v| option_v_to_s(v)}.join(',')
        when Set then option_v.map{|v| option_v_to_s(v)}.join('=')
        else
          option_v = (option_v || '').to_s
          option_v = option_v.gsub(/"/, '\"')
          option_v = "\"#{option_v}\"" if option_v.include?(' ')
          option_v
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
            if v.is_a?(Set)
              v.map {|vv| "#{k}=#{option_v_to_s(vv)}" }.join(' ')
            else
              "#{k}#{v.length > 0 ? "=#{v}" : ''}" # ex, --config-env=<name>=<envvar>
            end
          elsif k.start_with?(/-\w/)
            v = option_v_to_s(v)
            if v.is_a?(Set)
              v.map {|vv| "#{k} #{option_v_to_s(vv)}"}.join(' ')
            else
              "#{k} #{v}" # ex, -c <name>=<value>
            end
          elsif k == '--'
            if v.present?
              v = Array.wrap(v)
              v = v.map{|e| option_v_to_s(e)}.join(' ')
              targets = "-- #{v}" # ex, -- <args>
              ''
            end
          else
            raise "Unknown option: #{k}"
          end
        end

        parsed << targets
        parsed.join(' ')
      end
    end

    attr_reader :cmd, :sub_cmd, :args, :remain_args, :options, :str

    def initialize(cmd, *args, **options)
      arg_options = args.extract_options!
      options = options.merge(arg_options)
      @cmd = cmd
      @cmd, @sub_cmd = @cmd if @cmd.is_a?(Array)
      remain_ix = args.index{ |k| k == '--'}
      if remain_ix
        @remain_args = args[remain_ix+1..-1]
        @args = args[0...remain_ix]
      else
        @args = args
      end
      @args.delete_if do |arg|
        if arg.is_a?(self.class)
          options = arg.to_h.merge(options)
          true
        else
          false
        end
      end
      options['--'] ||= []
      options['--'] += @remain_args if @remain_args
      @options = options
      @args << self.class.options_to_s(options).strip
      @str = @args.join(' ')
    end

    def parser_proc(*args)
      raise 'Not implemented'
    end

    def parser
      parser_proc = parser_proc(@cmd, @sub_cmd)
      instance_exec(&parser_proc)
    end

    def to_h
      return @hash if defined?(@hash)
      @hash = {}
      remain_args = parser.parse!(@str.split(' '))
      @hash['--'] = remain_args if remain_args.any?
      @hash
    end
    delegate :[], :[]=, :key?, :map, :each, to: :to_h

    def merge(*args, **options)
      if args.first.is_a?(CmdOptions)
        other = args.shift
      else
        other = self.class.new([@cmd, @sub_cmd], *args, **options)
      end
      self.class.new(to_h.merge(other.to_h))
    end

    def to_s
      return self.class.options_h_to_s(@hash) if defined?(@hash)
      @str
    end
  end
end