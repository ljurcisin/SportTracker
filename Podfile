# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
  end

target 'Sports' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Sports

pod 'Firebase'  
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Database'
pod 'FDKeychain'

target 'SportsTests' do
    inherit! :search_paths
    pod 'Firebase'
end 

end
