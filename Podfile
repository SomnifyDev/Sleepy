# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Sleepy' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Sleepy
  pod 'SwiftLint'

  pod 'Armchair', '>= 0.3'

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

  target 'Sleepy_WatchOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Sleepy_WatchOSUITests' do
    # Pods for testing
  end

  target 'SleepyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SleepyUITests' do
    # Pods for testing
  end

end
