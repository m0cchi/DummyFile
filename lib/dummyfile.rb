require_relative "dummyfile/version"

module DummyFile

  def self.require!
    require_relative './file.rb'
  end

  def self.require
    if /^[2-9]\.[0-9]\.[0-9]/ === RUBY_VERSION
      require_relative './refinedummyfile.rb'
      RefineDummyFile::require
    end
  end

end
DummyFile::require!

fo = File.open('/Users/kazuto/temp/test.awk')
fo << "sdss"
puts fo.readlines
