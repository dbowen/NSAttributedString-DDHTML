Pod::Spec.new do |s|
  s.name      = 'NSAttributedString-DDHTML'
  s.version   = '1.0'
  s.license   = 'BSD'
  s.summary   = 'Simplifies working with NSAttributedString by allowing you to use HTML to describe formatting behaviors.'
  s.homepage  = 'https://github.com/dbowen/NSAttributedString-DDHTML'
  s.author    = { 'Derek Bowen' => 'dbowen@demiurgic.co' }
  s.source    = { :git => 'https://github.com/dbowen/NSAttributedString-DDHTML.git', :tag => "v#{s.version}" }
  s.description  = 'Simplifies working with NSAttributedString by allowing you to use HTML to describe formatting behaviors.'
  s.requires_arc = true
  s.ios.deployment_target = '6.1'

  s.source_files = 'NSAttributedString+DDHTML'
  s.libraries = 'xml2'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
end
