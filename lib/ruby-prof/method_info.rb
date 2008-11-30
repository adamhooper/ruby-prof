module RubyProf
  class MethodInfo
    include Comparable

    def <=>(other)
      if self.total_time < other.total_time
        -1
      elsif self.total_time > other.total_time
        1
      elsif self.min_depth < other.min_depth
        1
      elsif self.min_depth > other.min_depth
        -1
      else
        -1 * (self.full_name <=> other.full_name)
      end
    end

    def called
      @called ||= begin
        call_infos.inject(0) do |sum, call_info|
          sum += call_info.called
        end
      end
    end

    def total_time
      @total_time ||= begin
        call_infos.inject(0) do |sum, call_info|
          sum += call_info.total_time
        end
      end
    end
    
    def self_time
      @self_time ||= begin
        call_infos.inject(0) do |sum, call_info|
          sum += call_info.self_time
        end
      end
    end

    def wait_time
      @wait_time ||= begin
        call_infos.inject(0) do |sum, call_info|
          sum += call_info.wait_time
        end
      end
    end

    def children_time
      @children_time ||= begin
        call_infos.inject(0) do |sum, call_info|
          sum += call_info.children_time
        end
      end
    end

    def min_depth
      call_infos.map do |call_info|
        call_info.depth
      end.min
    end

    def root?
      @root ||= begin
        call_infos.find do |call_info|
          not call_info.root?
        end.nil?
      end
    end

    def children
      @children ||= begin
        call_infos.map do |call_info|
          call_info.children
        end.flatten
      end
    end

    def aggregate_parents
      aggregate_call_infos(self.call_infos)
    end

    def aggregate_children
      aggregate_call_infos(self.children)
    end

    def to_s
      full_name
    end

    private

    def aggregate_call_infos(call_infos)
      groups = call_infos.inject(Hash.new) do |hash, call_info|
        key = call_info.parent ? call_info.parent.target : self
        (hash[key] ||= []) << call_info
        hash
      end

      groups.map do |key, value|
        AggregateCallInfo.new(value)
      end
    end
  end
end