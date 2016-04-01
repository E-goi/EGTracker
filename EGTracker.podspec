#
# Be sure to run `pod lib lint EGTracker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "EGTracker"
  s.version          = "0.1.0"
  s.summary          = "EGTracker is used to track mobile events to the E-Goi platform."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
The Pod is used to track events to the E-Goi platform.
Then you can see how users are interacting with your mobile App.
                       DESC

  s.homepage         = "https://github.com/migchaves/EGTracker"
  s.license          = 'MIT'
  s.author           = { "Miguel Chaves" => "mchaves.apps@gmail.com" }
  s.source           = { :git => "https://github.com/migchaves/EGTracker.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'EGTracker' => ['Pod/Assets/*.png']
  }

  s.resources = 'Pod/Classes/TrackerDataBase/*.xcdatamodeld'
  s.frameworks = 'CoreData'

end
