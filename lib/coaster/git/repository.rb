module Coaster
  module Git
    class Repository
      class << self
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

        def run_cmd(path, command)
          puts "#{path}: #{command}"
          stdout, stderr, status = Open3.capture3(command, chdir: path)
          if status.success?
            puts "  ↳ success: #{stdout}"
            stdout
          else
            raise "Error executing command: #{command}\n  ↳ #{stderr}"
          end
        end

        def create(path)
          run_cmd(path.split('/')[0..-2].join('/'), "git init #{path}")
          run_cmd(path, "git commit --allow-empty -m 'initial commit'")
          new(path)
        end
      end

      attr_reader :path

      def initialize(path)
        @path = path
        @sha = current_sha
      end

      def run_cmd(command)
        self.class.run_cmd(path, command)
      end

      def run_git_cmd(command, *options)
        cmd = "git #{self.class.option_parser(options)} #{command}"
        run_cmd(cmd)
      end

      def add(*paths, **options)
        run_git_cmd("add #{self.class.hash_option_parser(options)} #{paths.join(' ')}")
      end

      def commit(message)
        run_git_cmd("commit -m \"#{message}\"")
      end

      def branch(name)
        run_git_cmd("branch #{name}")
      end

      def checkout(name)
        run_git_cmd("checkout #{name}")
      end

      def submodule_add!(path, url, git_options: {})
        run_git_cmd("submodule add #{url} #{path}", **git_options)
      end

      def submodule_init!(path)
        run_git_cmd("submodule init #{path}")
      end

      def submodule_update!(*paths, options: {})
        run_git_cmd("submodule update #{self.class.option_parser(options)} #{paths.join(' ')}")
      end

      def current_sha
        run_git_cmd('rev-parse HEAD').strip
      end

      def submodule_paths
        @submodule_paths ||= run_git_cmd('submodule status --recursive').split("\n").map do |line|
          line.split(' ')[1]
        end
      end

      def submodules
        @submodules ||= submodule_paths.map do |path|
          [path, Git::Repository.new(File.join(@path, path))]
        end.to_h
      end

      def merge(pointer)
        pointers = pointers(pointer).join(',')
        puts "#{path} merged deploy: #{pointers}"
        run_git_cmd("merge #{pointer} --commit -m \"merged deploy: #{pointers}\"")
      end

      def submodule_sha(path, pointer: nil)
        pointer ||= @sha
        run_git_cmd("ls-tree #{pointer} #{path}").split(' ')[2]
      end

      def deep_merge(pointer)
        submodules.values.each do |submodule|
          sm_sha = submodule_sha(submodule.path, pointer: pointer)
          submodule.merge(sm_sha)
        end
        merge(pointer)
      end

      def pointers(sha)
        run_git_cmd("branch --contains #{sha}").split("\n").map do |br|
          (br.start_with?('*') ? br[2..-1] : br).strip
        end
      end

      def remove
        self.class.run_cmd(path.split('/')[0..-2].join('/'), "rm -rf #{path}")
      end
    end
  end
end
