Pod::Spec.new do |s|
  s.name         = "ExtJSBridge"
  s.version      = "0.0.3"
  s.summary      = "A bridge between native and javascript"
  s.homepage     = "https://github.com/Pn-X/ExtJSBridge"
  s.license      = "MIT" 
  s.author       = { "pn-x" => "pannetez@163.com" }
  s.source       = { :git => "https://github.com/Pn-X/ExtJSBridge.git", :tag => "#{s.version}" }
  s.source_files  = "iOS/Classes", "iOS/Classes/**/*"
  s.exclude_files = "iOS/Classes/Exclude"
  s.ios.deployment_target = '9.0'
end
