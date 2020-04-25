Pod::Spec.new do |spec|
  spec.name         = "Shank"
  spec.version      = "1.0.0"
  spec.summary      = "A Swift micro-library that provides lightweight dependency injection."
  spec.description  = <<-DESC
  Read more here: https://basememara.com/swift-dependency-injection-via-property-wrapper/
                   DESC
  spec.homepage     = "https://basememara.com/swift-dependency-injection-via-property-wrapper/"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author    = "Zamzam Inc."
  spec.ios.deployment_target = "10.0"
  spec.osx.deployment_target = "10.12"
  spec.watchos.deployment_target = "3.0"
  spec.tvos.deployment_target = "10.0"
  spec.source       = { :git => "https://github.com/ZamzamInc/Shank.git" }
  spec.source_files  = "Sources/Shank"
end
