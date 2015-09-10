Gem::Specification.new do |s|
  s.name = "mcollective-test"
  s.version = "0.5"
  s.author = "R.I.Pienaar"
  s.email = "rip@devco.net"
  s.homepage = "https://github.com/keymone/mcollective-test"
  s.summary = "Test helper for MCollective"
  s.description = "Helpers, matchers and other utilities for writing agent, application and integration tests"
  s.files = Dir["lib/**/*"].to_a
  s.require_path = "lib"
  s.has_rdoc = false
end
