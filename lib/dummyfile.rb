require_relative "dummyfile/version"

module DummyFile

  def self.require!
    require_relative './file.rb'
  end

end
