Pod::Spec.new do |spec|
  spec.name         = "MZPay"
  spec.version      = "0.0.1"
  spec.summary      = "Swift微信支付和支付宝支付"
  spec.homepage     = "https://github.com/1691665955/MZPay"
  spec.authors         = { 'MZ' => '1691665955@qq.com' }
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.source = { :git => "https://github.com/1691665955/MZPay.git", :tag => spec.version}
  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }
  spec.requires_arc = true
  spec.platform     = :ios, "9.0"
  spec.swift_version = '5.0'
  spec.dependency 'WechatOpenSDK', '~> 1.8.7.1'
  spec.dependency 'AlipaySDK-iOS', '~> 15.8.10'
  spec.vendored_frameworks = "MZPay.framework"
end
