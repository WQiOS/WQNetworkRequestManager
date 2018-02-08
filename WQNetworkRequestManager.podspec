
Pod::Spec.new do |s|

s.name         = "WQNetworkRequestManager"
s.version      = "0.0.1"
s.summary      = "网络请求的私有库"

s.description  = <<-DESC
自己总结的网络请求的私有库，欢迎使用。
DESC


s.homepage     = "https://github.com/WQiOS/WQNetworkRequestManager"
s.license      = "MIT"
s.author       = { "王强" => "1570375769@qq.com" }
s.platform     = :ios, "8.0" #平台及支持的最低版本
s.requires_arc = true # 是否启用ARC
s.source       = { :git => "https://github.com/WQiOS/WQNetworkRequestManager.git", :tag => "#{s.version}" }
s.source_files = "WQNetworkRequestManager/*.{h,m}"
s.ios.framework  = 'UIKit'

end
