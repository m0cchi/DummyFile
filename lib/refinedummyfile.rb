module RefineDummyFile
  def self.require
    DummyFile.module_eval do
      refine File do
        DummyFile::require!
      end
    end
  end
end
