class Rails
  module VERSION
    MAJOR = 3
  end

  def self.env
    ActiveSupport::StringInquirer.new("test")
  end

  def self.root
    Pathname.new(File.dirname(__FILE__))
  end
end
