Pod::Spec.new do |s|
    s.name             = 'BeeJSON'
    s.version          = '2.0.2'
    s.summary          = 'Swift JSON encoder & decoder for Codable.'
    s.homepage         = 'https://github.com/xvwvx/BeeJSON'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'xvwvx' => 'jangsky215@gmail.com' }
    s.source           = { :git => 'https://github.com/xvwvx/BeeJSON.git', :tag => s.version.to_s }
    s.source_files     = 'Sources/**/**/*'
    
    s.ios.deployment_target = '11.0'
    s.osx.deployment_target = '10.10'
    s.tvos.deployment_target = '11.0'
    s.watchos.deployment_target = '2.0'
    s.swift_versions = ['5.2']
    s.dependency 'Runtime', '~> 2.2.2'
  end
