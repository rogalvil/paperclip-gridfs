# encoding: UTF-8
$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'paperclip-gridfs/version'

spec = Gem::Specification.new do |s|
  s.name          = "paperclip-gridfs"
  s.version       = Paperclip::GridFS::VERSION
  s.authors       = ["Blaž Hrastnik"]
  s.email         = "blaz.hrast@gmail.com"
  s.homepage      = "https://github.com/archSeer/paperclip-gridfs"
  s.description   = "Paperclip extension to support GridFS"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  #s.has_rdoc          = true
  #s.extra_rdoc_files  = Dir["README*"]
  #s.rdoc_options << '--line-numbers' << '--inline-source'

  s.add_dependency 'mongo', '>=1.1.4'
end
