
root = File.expand_path("../../../", __FILE__)
Dir["#{root}/spec/support/templates/*.rb"].each { |f| puts "requiring #{f}"; require f }
