use_frameworks!

def common_pods
  pod 'FMDB'
  pod 'YouTubePlayer', :git => 'https://github.com/gilesvangruisen/Swift-YouTube-Player.git', :tag => 'v0.5.0', :submodules => true
  pod 'Floaty', :git => 'https://github.com/kciter/KCFloatingActionButton.git', :tag => '4.1.0', :submodules => true  
end

def test_pods
  pod 'SwiftLint', '~> 0.42.0'  
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
