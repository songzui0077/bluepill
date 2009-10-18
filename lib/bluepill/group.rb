module Bluepill
  class Group
    attr_accessor :name, :processes, :logger
    attr_accessor :process_logger
    
    def initialize(name, options = {})
      self.name = name
      self.processes = []
      self.logger = options[:logger]
    end
    
    def add_process(process)
      process.logger = self.logger.prefix_with(process.name)
      self.processes << process
    end
    
    def tick
      self.each_process do |process|
        process.tick
      end
    end

    # proxied events
    [:start, :unmonitor, :stop, :restart].each do |event|
      eval <<-END
        def #{event}(process_name = nil)
          self.each_process do |process|
            process.dispatch!("#{event}") if process_name.nil? || process.name == process_name
          end
        end      
      END
    end
    
    protected
    
    def each_process(&block)
      self.processes.each(&block)
    end
  end
end