Pod::Spec.new do |s|
  s.name             = "PXCamera"
  s.version          = "0.1.6"
  s.summary          = "A camera and photo library library with class methods for ease."
  s.description      = <<-DESC
                       A couple of classes for presenting a camera that can pick from your photo library and a class for quickly prompting the user to pick from the photo library.
                       DESC
  s.homepage         = "https://github.com/pixio/PXCamera"
  s.license          = 'MIT'
  s.author           = { "Daniel Blakemore" => "DanBlakemore@gmail.com" }
  s.source = {
   :git => "https://github.com/pixio/PXCamera.git",
   :tag => s.version.to_s
  }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'PXCamera' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'AssetsLibrary', 'AVFoundation'
  s.dependency 'SVProgressHUD'
  s.dependency 'PXPinnedRotation'
end
