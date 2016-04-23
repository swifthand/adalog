require './lib/adalog'

Adalog.configure do |config|
  config.repo = Adalog::PStoreRepo.new('./tmp/test.pstore')
end

run Adalog::Web
