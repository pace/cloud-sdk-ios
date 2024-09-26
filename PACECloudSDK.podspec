Pod::Spec.new do |spec|
  spec.name                 = "PACECloudSDK"
  spec.version              = "24.0.0"
  spec.summary              = "Easily integrate your app with the PACE API to support Connected Fueling"
  spec.homepage             = "http://github.com/pace/cloud-sdk-ios"
  spec.license              = { :type => "MIT", :file => "LICENSE.md" }
  spec.author               = "PACE Telematics GmbH"
  spec.platform             = :ios, "15.0"
  spec.swift_version        = ["5.0"]
  spec.source               = { :git => "https://github.com/pace/cloud-sdk-ios.git", :tag => "#{spec.version}" }
  spec.source_files         = "PACECloudSDK/**/*.swift"
  spec.pod_target_xcconfig  = { 'PRODUCT_BUNDLE_IDENTIFIER': 'cloud.pace.sdk' }
  spec.resources            = ["PACECloudSDK/**/*.{strings,png}", "PACECloudSDK/Utils/**/*.plist"]
  spec.dependency "AppAuth"
  spec.dependency "SwiftProtobuf", "~> 1.22.0"
  spec.dependency "Japx"
end
