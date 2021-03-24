platform :ios, '9.0'
use_frameworks!

def common_pods
  pod 'FMDB'
  pod 'YouTubePlayer'
  pod 'Floaty'
  pod 'Swinject', '~> 2.7.1'
  pod 'SwinjectAutoregistration', '~> 2.7.0'
  pod 'SwinjectStoryboard', :git => 'https://github.com/Swinject/SwinjectStoryboard.git', :commit => '0ca45c83a8aa398c153d8a036c95abb4343cfa0c'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'AEXML'
end

def test_pods
  pod 'SwiftLint'
  pod 'Quick', '~> 3.0.0'
  pod 'Nimble', '~> 9.0.0'
  pod 'Cuckoo', '~> 1.4.1'
end

target "worshipsongs" do
  common_pods
end

target 'worshipsongsTests' do
  inherit! :search_paths
  common_pods
  test_pods  
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '5.0'
        end
    end
end
