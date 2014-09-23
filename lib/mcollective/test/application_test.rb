module MCollective
  module Test
    class ApplicationTest
      attr_reader :config, :logger, :application, :plugin

      include Test::Util

      def initialize(application, options={})
        config = options[:config] || {}
        facts = options[:facts] || {"fact" => "value"}

        ARGV.clear

        @config = create_config_mock(config)
        @application = application.to_s
        @logger = create_logger_mock
        @plugin = load_application(@application, options[:application_file])

        allow(@plugin).to receive(:printrpcstats)
        allow(@plugin).to receive(:puts)
        allow(@plugin).to receive(:printf)

        make_create_client
      end

      def make_create_client
        @plugin.instance_eval "
          def create_client(client)
              mock_client = double('client')
              allow(mock_client).to receive(:progress=)
              allow(mock_client).to receive(:progress)

              yield(mock_client) if block_given?

              expect_any_instance_of(MCollective::Application::Facts).to receive(:rpcclient).with(client).and_return(mock_client)

              mock_client
          end
        "
      end
    end
  end
end
