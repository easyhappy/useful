
class Record

  def around
    p "before"
    yield
    p "after"
  end

  def internal
    around do
      yield self
    end
  end

  def run
    value = nil
    internal do
      value = yield
    end
  end

  def save
    run do |a|
      p "save"
    end
  end

end

Record.new.save
