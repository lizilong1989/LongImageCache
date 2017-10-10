Pod::Spec.new do |spec|
  spec.name         = 'LongImageCache'
  spec.version      = '1.0.0'
  spec.license      = 'MIT'
  spec.summary      = 'An Objective-C tool for Cache'
  spec.homepage     = 'https://github.com/lizilong1989/LongImageCache'
  spec.author       = {'zilong.li' => '15131968@qq.com'}
  spec.source       =  {:git => 'https://github.com/lizilong1989/LongImageCache.git', :tag => spec.version.to_s }
  spec.source_files = "src/**/*.{h,m,mm}"
  spec.public_header_files = 'src/**/*.{h}'
  spec.platform     = :ios, '6.0'
  spec.requires_arc = true
  spec.frameworks   = 'Security'
  spec.xcconfig     = {'OTHER_LDFLAGS' => '-ObjC'}
end
