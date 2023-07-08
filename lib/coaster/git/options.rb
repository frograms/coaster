require 'coaster/cmd_options'

module Coaster
  module Git
    class Options < ::Coaster::CmdOptions
      OPTION_PARSER = {
        'git' => {
          nil => proc do
            OptionParser.new do |opts|
              opts.on('-c', '--config-env=NAME=VALUE') { |v|
                name, envvar = v.split('=')
                @hash['--config-env'] ||= {}
                @hash['--config-env'][name] = envvar
              }
            end
          end,
        },
        'config' => {
          nil => proc do
            OptionParser.new do |opts|
            end
          end,
        },
        'status' => {
          nil => proc do
            OptionParser.new do |opts|
            end
          end,
        },
        'add' => {
          nil => proc do
            OptionParser.new do |opts|
            end
          end,
        },
        'commit' => {
          nil => proc do
            OptionParser.new do |opts|
              opts.on('-m', '--message') { |v| @hash['--message'] = v }
            end
          end,
        },
        'fetch' => {
          nil => proc do
            OptionParser.new do |opts|
            end
          end,
        },
        'branch' => {
          nil => proc do
            OptionParser.new do |opts|
            end
          end
        },
        'checkout' => {
          nil => proc do
            OptionParser.new do |opts|
            end
          end
        },
        'merge' => {
          nil => proc do
            OptionParser.new do |opts|
              opts.on('-m', '--message') { |v| @hash['--message'] = v }
              opts.on('--no-commit') { |v| @hash['--no-commit'] = '' }
            end
          end
        },
        'log' => {
          nil => proc do
            OptionParser.new do |opts|
            end
          end
        },
        'diff' => {
          nil => proc do
            OptionParser.new do |opts|
            end
          end
        },
        'submodule' => {
          nil => proc do
            OptionParser.new do |opts|
            end
          end,
          'add' => proc do
            OptionParser.new do |opts|
            end
          end,
          'init' => proc do
            OptionParser.new do |opts|
            end
          end,
          'update' => proc do
            OptionParser.new do |opts|
            end
          end
        },
        'ls-tree' => {
          nil => proc do
            OptionParser.new do |opts|
            end
          end
        },
        'rev-parse' => {
          nil => proc do
            OptionParser.new do |opts|
            end
          end
        },
      }

      def parser_proc(cmd, sub_cmd, *args)
        OPTION_PARSER[cmd][sub_cmd]
      end
    end
  end
end
