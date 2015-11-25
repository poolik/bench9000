require 'thread'

class RBXFuture
  PENDING = Object.new

  def initialize
    @Lock      = Mutex.new
    @Condition = ConditionVariable.new
    # reference to a value with volatile semantics
    @Value     = Rubinius::AtomicReference.new PENDING

    # protect against reordering
    Rubinius.memory_barrier
  end

  def complete?(value = @Value.get)
    value != PENDING
  end

  def value
    # read only once
    value = @Value.get
    # check without synchronization
    return value if complete? value

    # critical section
    @Lock.synchronize do
      until complete?(value = @Value.get)
        # blocks thread until it is broadcasted
        @Condition.wait @Lock
      end
    end

    value
  end

  def fulfill(value)
    @Lock.synchronize do
      raise 'already fulfilled' if complete?
      @Value.set value
      @Condition.broadcast
    end

    self
  end
end


__END__

class RBXFuture
  PENDING = Object.new

  def initialize
    # final instance value (convention only)
    @Waiters = []
    # reference to a value with volatile semantics
    @Value   = Rubinius::AtomicReference.new PENDING

    # protect against reordering
    Rubinius.memory_barrier
  end

  def complete?(value = @Value.get)
    value != PENDING
  end

  def value
    # read only once
    value = @Value.get
    # check without synchronization
    return value if complete? value

    waiting_channel = nil
    Rubinius.synchronize(self) do
      # recheck
      value = @Value.get
      return value if complete?(value)

      waiting_channel = Rubinius::Channel.new
      @Waiters.push waiting_channel
    end
    # blocks until value is send to the channel
    waiting_channel.receive

    @Value.get
  end

  def fulfill(value)
    Rubinius.synchronize(self) do
      raise 'already fulfilled' if complete?
      @Value.set value
      @Waiters.each { |waiter| waiter << true }
      @Waiters.clear
    end

    self
  end
end
