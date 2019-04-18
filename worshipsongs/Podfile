use_frameworks!
target "worshipsongs" do
 pod 'FMDB'
 pod 'YouTubePlayer', :git => 'https://github.com/gilesvangruisen/Swift-YouTube-Player.git', :tag => 'v0.5.0', :submodules => true
 pod 'Floaty', :git => 'https://github.com/kciter/KCFloatingActionButton.git', :tag => '4.1.0', :submodules => true
end

target 'worshipsongsTests' do
  pod 'FMDB'
  pod 'YouTubePlayer', :git => 'https://github.com/gilesvangruisen/Swift-YouTube-Player.git', :tag => 'v0.5.0', :submodules => true
  pod 'Floaty', :git => 'https://github.com/kciter/KCFloatingActionButton.git', :tag => '4.1.0', :submodules => true
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end
