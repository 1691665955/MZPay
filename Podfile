platform :ios, '9.0'

target 'MZPay' do
  use_frameworks!

  pod 'WechatOpenSDK', '~> 1.8.7.1'
  pod 'AlipaySDK-iOS', '~> 15.8.10'

end

# 要使用OC的第三方库
static_frameworks = ['WechatOpenSDK', 'AlipaySDK-iOS']
pre_install do |installer|
  installer.pod_targets.each do |pod|
    # 注意这里和上面的不同
    if static_frameworks.include?(pod.name)
      def pod.static_framework?;
        true
      end
      def pod.build_type;
        Pod::BuildType.static_library
      end
    end
  end
end
