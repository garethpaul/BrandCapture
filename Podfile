platform :ios, '8.0'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'YES'
        end
    end
end

target "BrandCapture" do
  pod 'OpenCV', '2.4.9'
end
