# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'Sleepy' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Sleepy
  pod 'SwiftLint'
  pod 'SwiftFormat/CLI'

  pod 'Armchair', '>= 0.3'

  # add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  # or pod ‘Firebase/AnalyticsWithoutAdIdSupport’
  # for Analytics without IDFA collection capability

  # add pods for any other desired Firebase products
  # https://firebase.google.com/docs/ios/setup#available-pods

#Add the following in order to automatically set debug flags for armchair in debug builds
post_install do |installer|
      installer.pods_project.targets.each do |target|
          if target.name == 'Armchair'
              target.build_configurations.each do |config|
                  if config.name == 'Debug'
                      config.build_settings['OTHER_SWIFT_FLAGS'] = '-DDebug'
                      else
                      config.build_settings['OTHER_SWIFT_FLAGS'] = ''
                  end
              end
          end
      end
  end
end
