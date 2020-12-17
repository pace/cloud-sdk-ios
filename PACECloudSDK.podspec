Pod::Spec.new do |spec|
  spec.name                 = "PACECloudSDK"
  spec.version              = "2.0.1"
  spec.summary              = "Easily integrate your app with the PACE API to support Connected Fueling"
  spec.homepage             = "http://github.com/pace/cloud-sdk-ios"
  spec.license              = { :type => "MIT", :file => "LICENSE.md" }
  spec.author               = "PACE Telematics GmbH"
  spec.platform             = :ios, "11.0"
  spec.swift_version        = ["5.0"]
  spec.source               = { :git => "https://github.com/pace/cloud-sdk-ios.git", :tag => "#{spec.version}" }
  spec.source_files         = "PACECloudSDK/**/*.swift"
  spec.info_plist           = { 'CFBundleIdentifier' => 'cloud.pace.sdk' }
  spec.pod_target_xcconfig  = { 'PRODUCT_BUNDLE_IDENTIFIER': 'cloud.pace.sdk' }
  spec.resources            = "PACECloudSDK/**/*.{strings,png,otf}"
  spec.dependency "AppAuth"
  spec.dependency "SwiftProtobuf", "~> 1.13.0"
  spec.dependency "OneTimePassword", "~> 3.2.0"
end
