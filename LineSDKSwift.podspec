
Pod::Spec.new do |s|
  s.name                = "LineSDKSwift"
  s.version             = "5.5.2"
  s.summary             = "The LINE SDK for iOS Swift provides a modern way of implementing LINE APIs."

  s.description         = <<-DESC
                          Developed in Swift, the LINE SDK for iOS Swift provides a modern way of implementing 
                          LINE APIs. The features included in this SDK will help you develop an iOS app with 
                          engaging and personalized user experience.
                          DESC

  s.homepage            = "https://developers.line.biz/"
  s.license             = "Apache License, Version 2.0"

  s.author              = "LINE"
  s.platform            = :ios, "10.0"
  
  s.module_name         = "LineSDK"
  s.swift_version       = "4.2"
  s.swift_versions      = ["4.2", "5.0"]
  s.source              = { :git => "https://github.com/line/line-sdk-ios-swift.git", :tag => "#{s.version}" }

  s.default_subspecs    = "Core"
  s.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '-DLineSDKCocoaPods' }

  s.subspec "Core" do |sp|
    sp.source_files     = ["LineSDK/LineSDK/**/*.swift", "LineSDK/LineSDK/LineSDK.h"]
    sp.resource_bundles = { 'LineSDK' => ["LineSDK/LineSDK/Assets.xcassets", "LineSDK/LineSDK/Resource.bundle"] }
  end

  s.subspec "ObjC" do |sp|
    sp.source_files  = ["LineSDK/LineSDKObjC/**/*.swift", "LineSDK/LineSDKObjC/LineSDKObjC.h"]
    sp.dependency "LineSDKSwift/Core"
  end
  
end
