module Coaster
  module Git
    class Repository
      include Coaster::Git

      attr_reader :path

      def initialize(path)
        @path = path
        @sha = current_sha
      end

      def run_cmd(command, path: nil)
        super(path || @path, command)
      end

      def run_git_cmd(command, *options)
        cmd = "git #{option_parser(options)} #{command}"
        run_cmd(cmd)
      end

      def add(*paths, **options)
        run_git_cmd("add #{hash_option_parser(options)} #{paths.join(' ')}")
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
        run_git_cmd("submodule update #{option_parser(options)} #{paths.join(' ')}")
      end

      def fetch(remote = 'origin', *options)
        if remote.is_a?(Hash)
          options = remote
          remote = nil
        end
        run_git_cmd("fetch #{remote} #{option_parser(options)})")
      end

      def status(*pathspecs, **options)
        run_git_cmd("status #{option_parser(options)} #{pathspecs.join(' ')}")
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

      def merge(pointer, message: nil)
        pointers = pointers(pointer).join(',')
        message ||= "merge: #{pointers}"
        puts "[MERGE] #{path} #{message}"
        run_git_cmd("merge #{pointer} --commit -m \"#{message}\"")
      end

      def submodule_sha(path, pointer: nil)
        pointer ||= @sha
        run_git_cmd("ls-tree #{pointer} #{path}").split(' ')[2]
      end

      def deep_merge(pointer)
        puts "[DEEP_MERGE] #{path} #{pointer}"
        submodules.values.each do |submodule|
          sm_sha = submodule_sha(submodule.path, pointer: pointer)
          submodule.merge(sm_sha)
        end
        merge(pointer)
      end

      def pointers(sha)
        run_git_cmd("branch --contains #{sha}").split("\n").map do |br|
          br = (br.start_with?('*') ? br[2..-1] : br).strip
          next if br.match?(/^\(.*\)$/)
        end
      end

      def remove
        run_cmd("rm -rf #{path}", path: path.split('/')[0..-2].join('/'))
      end
    end
  end
end
