Pod::Spec.new do |s|
  s.name = 'CrossPlatformAuthentication'
  s.version = '1.0'
  s.license = 'BSD'
  s.summary = 'iOS library for the Cross-Platform Authentication Protocol (CPA)'
  s.homepage = 'https://tech.ebu.ch/cpa'
  s.authors = { 'Samuel Défago' => 'defagos@gmail.com', 'Michael Barroco' => 'barroco@ebu.ch' }
  s.source = { :git => 'https://github.com/ebu/cpa-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/EBU_TECH'
  s.platform = :ios, '7.0'
  
  s.description = <<-DESC
                  This project contains a reference implementation of the Cross-Platform Authentication client for iOS.

                  This software implements version 1.0 of the Cross-Platform Authentication Protocol (EBU Tech 3366)

                  More information on the EBU Cross-Platform Authentication project (https://tech.ebu.ch/cpa)
                  DESC
                  
  s.frameworks = 'Foundation', 'Security', 'UIKit'
  s.weak_frameworks = 'WebKit'

  s.requires_arc = true
  s.source_files = 'cpa-ios/Sources/**/*.{h,m}', 'cpa-ios/Externals/**/*.{h,m}', 'cpa-ios/Framework/**/*.{h,m}'
  s.public_header_files = 'cpa-ios/Framework/CrossPlatformAuthentication.h', 'cpa-ios/Sources/CPANullability.h', 'cpa-ios/Sources/CPAProvider.h', 'cpa-ios/Sources/CPAErrors.h', 'cpa-ios/Sources/CPAToken.h'

  s.resource_bundle = { 'CrossPlatformAuthentication-resources' => ['cpa-ios/Resources/{HTML,Images,Nibs}/*', 'cpa-ios/Resources/*.lproj'] }
end
