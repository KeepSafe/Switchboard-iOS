Pod::Spec.new do |spec|
  spec.name         = "Switchboard"
  spec.summary      = "A/B testing and feature flags for iOS built on top of Switchboard."
  spec.version      = "0.2.0"
  spec.homepage     = "https://github.com/KeepSafe/Switchboard-iOS"
  spec.license      = { :type => "Apache 2.0", :file => "LICENSE" }
  spec.authors      = { "Keepsafe" => "philipp@getkeepsafe.com" }
  spec.source       = { :git => "https://github.com/KeepSafe/Switchboard-iOS.git", :tag => "v" + spec.version.to_s }
  spec.source_files = "Switchboard/Source/**/*"
  spec.ios.deployment_target = "10.0"
  spec.osx.deployment_target = "10.12"
  spec.requires_arc = true
end