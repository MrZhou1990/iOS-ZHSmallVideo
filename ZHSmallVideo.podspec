Pod::Spec.new do |s|
  s.name         = "ZHSmallVideo"
  s.version      = "0.0.1"
  s.summary      = "Imitate WeChat small video function."
  s.homepage     = "https://github.com/MrZhou1990/ZHSmallVideo"
  s.license      = "MIT"
  s.author       = {"Cloud" => "haohao10987@163.com"}
  s.platform     = :ios, "8.0"
  s.source       = {:git => "https://github.com/MrZhou1990/ZHSmallVideo.git", :tag => "#{s.version}"}
  s.source_files = "ZHSmallVideoDemo/ZHSmallVideoDemo/ZHSmallVideo/**/*.{h,m}"
  s.resources    = "ZHSmallVideoDemo/ZHSmallVideoDemo/ZHSmallVideo/VideoImages/*.png"
  s.requires_arc = true
end
