require 'spec_helper'

describe Dummyfile do
  it 'has a version number' do
    expect(Dummyfile::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
