Pod::Spec.new do |tapViewController|
    
    tapViewController.platform = :ios
    tapViewController.ios.deployment_target = '10.0'
    tapViewController.swift_version = '4.1'
    tapViewController.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }
    tapViewController.name = 'TapViewControllerV2'
    tapViewController.summary = 'Set of Base View Controllers.'
    tapViewController.requires_arc = true
    tapViewController.version = '1.0.0'
    tapViewController.license = { :type => 'MIT', :file => 'LICENSE' }
    tapViewController.author = { 'Osama Rabie' => 'o.rabie@tap.company' }
    tapViewController.homepage = 'https://github.com/Tap-Payments/TapViewControllerV2'
    tapViewController.source = { :git => 'https://github.com/Tap-Payments/TapViewControllerV2.git', :tag => tapViewController.version.to_s }
    tapViewController.source_files = 'TapViewController/Source/*.swift'
    tapViewController.ios.resource_bundle = { 'TapViewControllerResources' => 'TapViewController/Resources/*.{storyboard,xcassets}' }
    
    tapViewController.dependency 'TapAdditionsKitV2'
    tapViewController.dependency 'TapApplicationV2'
    tapViewController.dependency 'TapFontsKitV2'
    tapViewController.dependency 'TapLocalizationV2'
    tapViewController.dependency 'TapLoggerV2'
    tapViewController.dependency 'TapSearchViewV2'
    tapViewController.dependency 'TapVisualEffectViewV2'    
end
