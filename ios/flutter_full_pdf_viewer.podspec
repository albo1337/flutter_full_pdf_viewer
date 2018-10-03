#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_full_pdf_viewer'
  s.version          = '1.0.0'
  s.summary          = 'A fully functional on both platforms pdf viewer.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'https://github.com/albo1337'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Alban Veliu' => 'alveliu93@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.ios.deployment_target = '8.0'
end

