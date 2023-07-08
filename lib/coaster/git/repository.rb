module Coaster
  module Git
    class Repository
      include Coaster::Git

      attr_reader :path

      def initialize(path)
        @path = path
      end

      def run_cmd(command, path: nil)
        super(path || @path, command)
      end

      def with_git_options(*args, **options, &block)
        @git_options = Options.new('git', *args, **options)
        yield
        @git_options = nil
      end

      def run_git_cmd(command, *args, **options)
        opts = Options.new(command, *args, **options)
        cmd = "git #{@git_options} #{Array.wrap(command).join(' ')} #{opts}"
        run_cmd(cmd)
      end

      def add(*paths, **options)
        opts = Options.new('add', **options)
        run_git_cmd("add", *paths, opts)
      end

      def commit(*args, **options)
        opts = Options.new('commit', *options)
        opts['--message'] ||= "no message"
        run_git_cmd("commit", opts)
      end

      def branch(*args, **options)
        run_git_cmd("branch", *args, **options)
      end

      def checkout(*args, **options)
        run_git_cmd("checkout", *args, **options)
      end

      def submodule_add!(repo, path, *args, **options)
        run_git_cmd(["submodule", 'add'], repo, path, *args, **options)
      end

      def submodule_init!(*paths)
        run_git_cmd(["submodule", "init"], *paths)
      end

      def submodule_update!(*paths, **options)
        run_git_cmd(["submodule", "update"], *paths, **options)
      end

      def fetch(*args, **options)
        run_git_cmd("fetch", *args, **options)
      end

      def status(*args, **options)
        run_git_cmd("status", *args, **options)
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

      def merge(pointer, *args, **options)
        opts = Options.new('merge', *args, **options)
        pointers = pointers(pointer).join(',')
        puts "[MERGE] #{path} #{pointers} #{options}"
        opts['--message'] ||= "Merge #{pointers}"
        run_git_cmd("merge #{pointer} #{opts}")
      end

      def submodule_sha(path, pointer: nil)
        pointer ||= current_sha
        run_git_cmd("ls-tree #{pointer} #{path}").split(' ')[2]
      end

      def merge_without_submodules
        run_git_cmd('config merge.ours.name "Keep ours merge driver"')
        run_git_cmd('config merge.ours.driver true')
        ga_file = File.join(@path, '.gitattributes')
        run_cmd("touch #{ga_file}")
        ga_lines = File.read(ga_file).split("\n")
        ga_lines_appended = ga_lines + submodules.keys.map{|sb_path| "#{sb_path} merge=ours" }
        File.open(ga_file, 'w') do |f|
          f.puts ga_lines_appended.join("\n")
        end
        add('.')
        commit
        yield
        File.open(ga_file, 'w') do |f|
          f.puts ga_lines.join("\n")
        end
      end

      def deep_merge(pointer)
        puts "[DEEP_MERGE] #{path} #{pointer}"
        submodules.values.each do |submodule|
          sm_sha = submodule_sha(submodule.path, pointer: pointer)
          submodule.merge(sm_sha)
        end
        merge_without_submodules do
          merge(pointer)
        end
      end

      def pointers(sha)
        run_git_cmd("branch --contains #{sha}").split("\n").map do |br|
          br = (br.start_with?('*') ? br[2..-1] : br).strip
          br.match?(/^\(.*\)$/) ? nil : br
        end.compact
      end

      def remove
        run_cmd("rm -rf #{path}", path: path.split('/')[0..-2].join('/'))
      end
    end
  end
end
