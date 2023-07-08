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

require 'coaster/git/options'
require 'coaster/git/repository'
