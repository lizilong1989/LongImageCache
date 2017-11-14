Pod::Spec.new do |spec|
  spec.name         = 'LongImageCache'
  spec.version      = '1.0.4'
  spec.license       = { :type => 'Personal', :text => 'zilong.li' }
  spec.summary      = 'An Objective-C tool for Cache'
  spec.homepage     = 'https://github.com/lizilong1989/LongImageCache'
  spec.author       = {'zilong.li' => '15131968@qq.com'}
  spec.source       =  {:git => 'https://github.com/lizilong1989/LongImageCache.git', :tag => spec.version.to_s }
  spec.platform     = :ios, '6.0'
  spec.requires_arc = true
  spec.frameworks   = 'Security'
  spec.xcconfig     = {'OTHER_LDFLAGS' => '-ObjC'}
  spec.dependency   'LongDispatch', '~> 1.0.3'
  spec.dependency   'LongRequest', '~> 1.0.1'

  spec.default_subspec = 'Core'

  spec.subspec 'Core' do |core|
    core.source_files = 'src/**/*.{h,m,mm}'
    core.public_header_files = 'src/**/*.{h}'
  end

  spec.subspec 'WebP' do |webp|
    webp.source_files = '3rdparty/webp/include/*.h'
    webp.vendored_libraries = ['3rdparty/webp/lib/libwebp.a','3rdparty/webp/lib/libwebpdecoder.a']
    webp.xcconfig = { 
        'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) LONG_WEBP=1'
    }
  end
end
