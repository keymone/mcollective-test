module MCollective
  module Test
    module Util
      def create_facts_mock(factsource)
        facts = double('facts')
        allow(facts).to receive(:get_facts).and_return(factsource)

        factsource.each_pair do |k, v|
          allow(facts).to receive(:get_fact).with(k).and_return(v)
        end

        PluginManager << {:type => "facts_plugin", :class => facts, :single_instance => false}
      end

      def create_config_mock(config)
        pluginconf = {}

        cfg = double('config')
        allow(cfg).to receive(:configured).and_return(true)
        allow(cfg).to receive(:rpcauthorization).and_return(false)
        allow(cfg).to receive(:rpcaudit).and_return(false)
        allow(cfg).to receive(:main_collective).and_return("mcollective")
        allow(cfg).to receive(:collectives).and_return(["production", "staging"])
        allow(cfg).to receive(:classesfile).and_return("classes.txt")
        allow(cfg).to receive(:identity).and_return("rspec_tests")
        allow(cfg).to receive(:logger_type).and_return("console")
        allow(cfg).to receive(:loglevel).and_return("error")
        allow(cfg).to receive(:pluginconf).and_return(pluginconf)

        if config
          config.each_pair do |k, v|
            allow(cfg).to receive(k).and_return(v)
            if k =~ /^plugin.(.+)/
              pluginconf[$1] = v
            end
          end

          if config.include?(:libdir)
            [config[:libdir]].flatten.each do |dir|
              $: << dir if File.exist?(dir)
            end

            allow(cfg).to receive(:libdir).and_return(config[:libdir])
          end
        end


        allow(Config).to receive(:instance).and_return(cfg)

        cfg
      end

      def mock_validators
        allow(Validator).to receive(:load_validators)
        allow(Validator).to receive(:validate).and_return(true)
      end

      def create_logger_mock
        logger = double('logger')

        [:log, :start, :debug, :info, :warn].each do |meth|
          allow(logger).to receive(meth)
        end

        expect(Log).to receive(:config_and_check_level).at_most(:once).and_return(false)

        Log.configure(logger)

        logger
      end

      def create_connector_mock
        connector = double('connector')

        [:connect, :receive, :publish, :subscribe, :unsubscribe, :disconnect].each do |meth|
          allow(connector).to receive(meth)
        end

        PluginManager << {:type => "connector_plugin", :class => connector}

        connector
      end

      def load_application(application, application_file=nil)
        classname = "MCollective::Application::#{application.capitalize}"
        PluginManager.delete("#{application}_application")

        if application_file
          raise "Cannot find application file #{application_file} for application #{application}" unless File.exist?(application_file)
          load application_file
        else
          PluginManager.loadclass(classname)
        end

        PluginManager << {:type => "#{application}_application", :class => classname, :single_instance => false}
        PluginManager["#{application}_application"]
      end

      def load_agent(agent, agent_file=nil)
        classname = "MCollective::Agent::#{agent.capitalize}"

        PluginManager.delete("#{agent}_agent")

        if agent_file
          raise "Cannot find agent file #{agent_file} for agent #{agent}" unless File.exist?(agent_file)
          load agent_file
        else
          PluginManager.loadclass(classname)
        end

        klass = Agent.const_get(agent.capitalize)

        allow(klass).to receive("load_ddl").and_return(true)
        # [2015-04-25 Christo] For some STUPID reason neither Mocha::Mock NOR RSpec::Mocks can trap the validate! ... :( So we will just Stub the entire damn class!!!
        # RPC::Request.stub(:validate!).and_return(true)
        stub_const("MCollective::RPC::Request", MCollective::RPC::StubRequest)

        PluginManager << {:type => "#{agent}_agent", :class => classname, :single_instance => false}
        PluginManager["#{agent}_agent"]
      end

      def create_response(senderid, data = {}, stats = nil , statuscode = 0, statusmsg = "OK")
        unless stats == nil
          {:senderid => senderid, :body =>{:data => data, :stats => stats}}
        else
          {:senderid => senderid, :body =>{:data => data}}
        end
      end
    end
  end
end

module MCollective
  module RPC
    class StubRequest < Request
      # include RSpec::Mocks
      # include RSpec::Mocks::Methods
      # include RSpec::Mocks::AnyInstance
      # include RSpec::Mocks::ExampleMethods
      # def initialize(msg, ddl)
      #   super(msg, ddl)
      #   # self.stub(:validate! => true)
      # end
      def validate!
        true
      end
    end
  end
end
