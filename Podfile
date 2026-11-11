# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'alliage-macaw-poc' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for alliage-macaw-poc
    
    #pod "Macaw", "0.9.5"
    pod "Macaw",  git: "https://github.com/exyte/Macaw.git" , commit:"34292e6e2b9f0b2cb59ac7ef51ed225c1fe3bdff"
    
    pod 'IQKeyboardManagerSwift', '6.2.1'
    pod 'SnapKit', '~> 5.0.0'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 12.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end
end
