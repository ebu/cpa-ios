platform :ios, '7.0'

inhibit_all_warnings!

# Avoid CocoaPods picking up any name
workspace 'cpa-ios'

# Must declare all projects so that the workspace is generated with all of them
# (even if not all projects have Pods dependencies)
xcodeproj 'cpa-ios/cpa-ios.xcodeproj'
xcodeproj 'cpa-ios-demo/cpa-ios-demo.xcodeproj'
xcodeproj 'cpa-ios-tests/cpa-ios-tests-runner.xcodeproj'

target 'cpa-ios-tests' do
	xcodeproj 'cpa-ios-tests/cpa-ios-tests-runner.xcodeproj'
	pod 'VCRURLConnection', '0.2.0'
end
