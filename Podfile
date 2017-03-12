source 'https://github.com/CocoaPods/Specs.git'
platform :osx, '10.9'
use_frameworks!
inhibit_all_warnings!

pod 'RealmSwift'

post_install do |installer|
    installer.pods_project.targets.each do |target|

        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = "3.0"

        end
    end
end

target 'iBeaconManager'
