platform :ios, '9.0'
use_frameworks!

def common_pods
  pod 'FMDB'
  pod 'YouTubePlayer'
  pod 'Floaty'
end

def test_pods
  pod 'SwiftLint'
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
