# Uncomment the next line to define a global platform for your project
platform :osx, '10.10'

target 'TySimulator' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TySimulator
  pod 'MASShortcut'
  pod 'MASPreferences'
  pod 'DevMateKit'
  pod 'ACEViewSwift', :git => 'https://github.com/ty0x2333/ACEViewSwift.git', :branch => 'fix_jsCall_error', :submodules => true
  pod 'Fabric'
  pod 'Crashlytics'

  target 'TySimulatorTests' do
    inherit! :search_paths
  end

end
