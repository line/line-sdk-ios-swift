
Pod::Spec.new do |s|
  s.name         = "LineSDKObjC"
  s.version      = "5.0.0"
  s.summary      = "Integrate LINE Login and APIs into your iOS app to create a more engaging experience for your users."

  s.description  = <<-DESC
                    The LineSDK lets you integrate LINE into your iOS app to create a more engaging 
                    experience for your users. This framework is written as an Objective-C wrapper 
                    for pure Swift implmentation of LineSDK and provides an easy way to integrate 
                    LINE login, LINE APIs and other exciting features into your app.
                   DESC

  s.homepage     = "https://developers.line.me/"
  s.license      = "Apache License, Version 2.0"

  s.author    = "LINE"
  s.platform     = :ios, "10.0"
  
  s.module_name   = "LineSDKObjC"
  s.swift_version = '4.2'

  s.source       = { :git => "https://github.com/line/linesdk-ios-swift.git", :tag => "#{s.version}" }
  s.source_files  = ["LineSDK/LineSDKObjC/**/*.swift", "LineSDK/LineSDKObjC/LineSDKObjC.h"]
  s.dependency "LineSDKSwift", "~> #{s.version}"
end
