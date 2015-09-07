#
# Be sure to run `pod lib lint IFCacheKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "IFCacheKit"
  s.version          = "0.0.1"
  s.summary          = "A caching library in Swift that's simple to use"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                       A Disk and LRU memory cache that is designed to be simple to use while being performant
                       DESC

  s.homepage         = "https://github.com/ivanfoong/IFCacheKit-Swift"
  s.license          = 'MIT'
  s.author           = { "Ivan Foong" => "vonze21@gmail.com" }
  s.source           = { :git => "https://github.com/ivanfoong/IFCacheKit-Swift.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/vonze21'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
end
