#
# Be sure to run `pod lib lint MKNearbyInteraction.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MKNearbyInteraction'
  s.version          = '0.0.1'
  s.summary          = 'A short description of MKNearbyInteraction.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/lovexiaoxia/MKNearbyInteraction'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lovexiaoxia' => 'aadyx2007@163.com' }
  s.source           = { :git => 'https://github.com/lovexiaoxia/MKNearbyInteraction.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '16.0'
  
  s.resource_bundles = {
    'MKNearbyInteraction' => ['MKNearbyInteraction/Assets/*']
  }
  
  s.subspec 'Target' do |ss|
    
    ss.source_files = 'MKNearbyInteraction/Classes/Target/**'
    
    ss.dependency 'MKBaseModuleLibrary'
    ss.dependency 'MKNearbyInteraction/Functions'
  
  end
  
  s.subspec 'CTMediator' do |ss|
    
    ss.source_files = 'MKNearbyInteraction/Classes/CTMediator/**'
    
    ss.dependency 'CTMediator'
    ss.dependency 'MKBaseModuleLibrary'
  
  end
  
  s.subspec 'Expand' do |ss|
    
    ss.subspec 'EmitterLayerView' do |sss|
      sss.source_files = 'MKNearbyInteraction/Classes/Expand/EmitterLayerView/**'
    end
  
    ss.subspec 'LoadingLabel' do |sss|
      sss.source_files = 'MKNearbyInteraction/Classes/Expand/LoadingLabel/**'
    end
    
    ss.subspec 'WaveView' do |sss|
      sss.source_files = 'MKNearbyInteraction/Classes/Expand/WaveView/**'
    end
    
    ss.dependency 'MKBaseModuleLibrary'
  
  end
  
  s.subspec 'SDK' do |ss|
    ss.source_files = 'MKNearbyInteraction/Classes/SDK/**'
    
    ss.dependency 'MKBaseBleModule'
  end
  
  s.subspec 'Functions' do |ss|
    
    ss.subspec 'AboutPage' do |sss|
        sss.subspec 'Controller' do |ssss|
          ssss.source_files = 'MKNearbyInteraction/Classes/Functions/AboutPage/Controller/**'
          
          ssss.dependency 'MKNearbyInteraction/Functions/AboutPage/View'
        end
        
        sss.subspec 'View' do |ssss|
          ssss.source_files = 'MKNearbyInteraction/Classes/Functions/AboutPage/View/**'
        end
    end
    
    ss.subspec 'MainDataPage' do |sss|
        sss.subspec 'Controller' do |ssss|
          ssss.source_files = 'MKNearbyInteraction/Classes/Functions/MainDataPage/Controller/**'
          
          ssss.dependency 'MKNearbyInteraction/Functions/MainDataPage/View'
        end
        
        sss.subspec 'View' do |ssss|
          ssss.source_files = 'MKNearbyInteraction/Classes/Functions/MainDataPage/View/**'
        end
    end
    
    ss.subspec 'ScanPage' do |sss|
        sss.subspec 'Controller' do |ssss|
          ssss.source_files = 'MKNearbyInteraction/Classes/Functions/ScanPage/Controller/**'
          
          ssss.dependency 'MKNearbyInteraction/Functions/ScanPage/View'
          
          ssss.dependency 'MKNearbyInteraction/Functions/MainDataPage/Controller'
          ssss.dependency 'MKNearbyInteraction/Functions/AboutPage/Controller'
        end
        
        sss.subspec 'View' do |ssss|
          ssss.source_files = 'MKNearbyInteraction/Classes/Functions/ScanPage/View/**'
        end
    end
    
    ss.dependency 'MKNearbyInteraction/SDK'
    ss.dependency 'MKNearbyInteraction/Expand'
    ss.dependency 'MKNearbyInteraction/CTMediator'
  
    ss.dependency 'MKBaseModuleLibrary'
    ss.dependency 'MKCustomUIModule'
    
    ss.dependency 'MLInputDodger'
    ss.dependency 'SDCycleScrollView','>= 1.82'
    ss.dependency 'MLInputDodger'
#    ss.dependency 'SVGKit'
#    ss.dependency 'SYNoticeBrowseLabel'
    
  end

end
