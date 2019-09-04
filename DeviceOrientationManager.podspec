
Pod::Spec.new do |s|
  s.name             = 'DeviceOrientationManager'
  s.version          = '1.0.0'
  s.summary          = 'DeviceOrientationManager.'
  s.homepage         = 'https://github.com/huawtswork/DeviceOrientationManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'huawt' => 'ghost263sky@163.com' }
  s.source           = { :git => 'https://github.com/huawtswork/DeviceOrientationManager.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'DeviceOrientationManager/Classes/**/*'
  s.public_header_files = 'DeviceOrientationManager/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
end
