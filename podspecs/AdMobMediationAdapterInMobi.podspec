Pod::Spec.new do |s|
  s.name         = "AdMobMediationAdapterInMobi"
  s.version      = "0.0.1"
  s.summary      = "A short description of AdMobMediationAdapterInMobi."

  s.description  = "InMobi adapter for AdMob Mediation."
  s.homepage     = "https://developers.google.com/mobile-ads-sdk/docs/admob/mediation-networks"

  s.license      = { :type => 'Copyright', :text => 'Copyright (c) 2013 InMobi.' }
  s.author       = { "InMobi" => "unknown" }

  s.platform     = :ios

  s.source = { :http => "https://dl.inmobi.com/SDK/Adapters/AdMobMediation_Adapter_InMobi_iOS_SDK.zip", :flatten => true }

  s.source_files  = 'AdapterInMobi/**/*.{h,m}'
  s.preserve_paths = "*.a"

  s.xcconfig = { 'LIBRARY_SEARCH_PATHS' => '$(PODS_ROOT)/AdapterInMobi/' }
  s.dependency 'InMobiSDK'

end
