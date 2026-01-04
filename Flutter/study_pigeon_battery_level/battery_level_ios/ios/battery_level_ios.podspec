Pod::Spec.new do |s|
  s.name             = 'battery_level_ios'
  s.version          = '1.0.0'
  s.summary          = 'iOS implementation of battery_level plugin.'
  s.description      = <<-DESC
iOS implementation of the battery_level plugin.
                       DESC
  s.homepage         = 'https://github.com/example/battery_level'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version    = '5.0'
end
