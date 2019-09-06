#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_full_pdf_viewer'
  s.version          = '1.0.1'
  s.summary          = 'A fully functional pdf viewer for both iOS and Android.'
  s.description      = <<-DESC
A fully functional pdf viewer for both iOS and Android.
                       DESC
  s.homepage         = 'https://github.com/albo1337'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Alban Veliu' => 'alveliu93@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.framework        = 'WebKit'
  
  s.ios.deployment_target = '8.0'
end

