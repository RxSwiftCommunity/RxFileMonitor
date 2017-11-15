Pod::Spec.new do |s|
  s.name             = "RxFileMonitor"
  s.version          = "1.2.1"
  s.summary          = "RxSwift reactive wrapper for Mac file system events."

  s.description      = <<-DESC
CoreFoundation file system even wrapper for RxSwift which lets you
monitor folders for content changes and file updates.
DESC

  s.homepage         = "https://github.com/RxSwiftCommunity/RxFileMonitor"
  s.license          = 'MIT'
  s.author           = { "Christian Tietze" => "hi@christiantietze.de" }
  s.source           = { :git => "https://github.com/RxSwiftCommunity/RxFileMonitor.git", :tag => s.version.to_s }

  s.requires_arc = true

  s.osx.deployment_target = '10.11'
  
  s.source_files     = 'RxFileMonitor/*.swift'
  s.osx.source_files = 'RxFileMonitor/*.swift'
  
  s.dependency 'RxSwift', '~> 4.0'
end
