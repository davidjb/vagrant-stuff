# -*- mode: ruby -*-
# vi: set ft=ruby :

#Basic hacky-plugin that just runs multiple Vagrant commands in sequence.
require Vagrant.source_root.join("plugins/commands/up/start_mixins")

module VagrantPlugins
  module CommandCompile
    class Command < Vagrant.plugin("2", :command)
      include VagrantPlugins::CommandUp::StartMixins
      def execute
        options = {}
        opts = OptionParser.new do |o|
          o.banner = "Usage: vagrant compile [vm-name]"
          o.separator ""
          build_start_options(o, options)
          o.on("-f", "--force", "Force destroy VM when complete") do |v|
            options[:verbose] = v
          end
        end

        # Parse the options
        argv = parse_options(opts)
        return if !argv

        with_target_vms(argv) do |machine|
          [:up, :destroy].each do |action|
            machine.action(action, options)
          end
        end
        0
      end
    end

    class Plugin < Vagrant.plugin("2")
      name "compile command"
      description <<-DESC
      This command is simple - it creates, provisions, and then destroys
      the target VM.
      DESC

      command("compile") do
        Command
      end
    end
  end
end
