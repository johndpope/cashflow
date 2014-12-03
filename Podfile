source 'https://github.com/CocoaPods/Specs.git'
platform :ios,'8.0'

link_with ['CashFlow', 'CashFlowFree', 'UnitTests']

pod 'Dropbox-iOS-SDK'

pod 'CrashlyticsFramework'
#pod 'BugSense'
#pod 'CrittercismSDK'

pod 'GoogleAnalytics-iOS-SDK'

pod 'RDVCalendarView', '~> 1.0.7'

target :lite do
  link_with 'CashFlowFree'

  pod 'Google-Mobile-Ads-SDK'
  pod 'AdMobMediationAdapterIAd'

  ### うまく動作しないため、一旦解除
  #pod 'InMobiSDK'
  #pod 'AdMobMediationAdapterInMobi', :podspec => './podspecs/AdMobMediationAdapterInMobi.podspec'
  #pod 'AdMobMediationAdapterInMobi'

  # Adapter iMobile deps
  #pod 'ASIHTTPRequest'
  #pod 'JSONKit'
end




