source 'https://github.com/CocoaPods/Specs'

platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

target 'bclub' do
  pod 'Pluralize.swift', :git => 'https://github.com/joshualat/Pluralize.swift', :branch => 'master'
  pod 'Fabric', '~> 1.6'
  pod 'Crashlytics', '~> 3.7'
  pod 'Google/Analytics'
  pod 'Stripe'
  pod 'SwiftyColor'
  pod 'Eureka', '~> 1.6.0'  
  pod 'SnapKit', '~> 0.15.0'
  pod 'KeychainAccess'
  pod 'MRProgress'
  pod 'VMaskTextField'
  pod 'Nuke'
  pod 'PhoneNumberKit', '~> 0.8'
  pod 'Backendless-ios-SDK'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
end



# Copy acknowledgements to the Settings.bundle

post_install do | installer |
  require 'fileutils'

  pods_acknowledgements_path = 'Pods/Target Support Files/Pods/Pods-Acknowledgements.plist'
  settings_bundle_path = Dir.glob("**/*Settings.bundle*").first

  if File.file?(pods_acknowledgements_path)
    puts 'Copying acknowledgements to Settings.bundle'
    FileUtils.cp_r(pods_acknowledgements_path, "#{settings_bundle_path}/Acknowledgements.plist", :remove_destination => true)
  end
end

