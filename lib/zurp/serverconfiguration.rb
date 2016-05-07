class ServerConfiguration
  @@configuration = {}

  def self.set(property, value)
    @@configuration[property] = value
  end

  def self.get(property)
    @@configuration[property]
  end

  def self.delete(property)
    @@configuration.delete property
  end

  def self.raw
    @@configuration
  end

end