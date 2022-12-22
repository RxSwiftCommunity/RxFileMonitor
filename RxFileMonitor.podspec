Pod::Spec.new do |s|
  s.name             = "RxFileMonitor"
  s.version          = "4.0.0"
  s.summary          = "RxSwift reactive wrapper for Mac file system events."

  s.description      = <<-DESC
CoreFoundation file system even wrapper for RxSwift which lets you
monitor folders for content changes and file updates.
DESC

  s.homepage         = "https://github.com/RxSwiftCommunity/RxFileMonitor"
  s.license          = 'MIT'
  s.author           = { "Christian Tietze" => "hi@christiantietze.de" }
  s.source           = { :git => "https://github.com/RxSwiftCommunity/RxFileMonitor.git", :tag => s.version.to_s }

  s.osx.deployment_target = '10.11'
  s.swift_versions   = ['4.2', '5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7']
  s.requires_arc     = true

  s.source_files     = 'RxFileMonitor/*.swift'
  s.osx.source_files = 'RxFileMonitor/*.swift'

  s.dependency 'RxSwift', '~> 6.0'
end
