# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'GDONG' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GDONG
pod 'Tabman', '~> 2.9'
pod 'DLRadioButton', '~> 1.4'
pod 'PagingTableView'

pod 'KakaoSDKAuth'  # 카카오 로그인
pod 'KakaoSDKUser'
pod 'KakaoSDKCommon'
pod 'KakaoOpenSDK'

pod 'GoogleSignIn' #구글 로그인

pod "TTGTagCollectionView"
pod 'Alamofire', '~> 5.2'
pod 'MessageKit'
pod 'Scaledrone', '~> 0.3.0'

pod 'Firebase/Analytics'
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'
pod 'Firebase/Firestore'

pod 'JGProgressHUD'
pod 'Kingfisher', '~> 6.0'
pod 'SDWebImage', '~> 5.0'
pod 'DropDown'
pod 'InputBarAccessoryView'

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
            config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        end
    end
end


end
