platform :ios, '10.0'
use_frameworks!

workspace 'PantauBersama'

project 'PantauBersama/PantauBersama.xcodeproj'
project 'Common/Common.xcodeproj'


def application_rx 
    pod 'RxSwift', '4.4.0'
    pod 'RxCocoa', '4.4.0'

end


def networking_pods
    application_rx
    pod 'Moya/RxSwift', '12.0.1'
    pod 'RxDataSources', '~> 3.1.0'
end


def application_pods
    pod 'Firebase/Core'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'IQKeyboardManagerSwift', '~> 6.2.0'
    pod 'AlamofireImage'
    pod 'LTHRadioButton'
    pod 'TwitterKit'
    pod 'FBSDKLoginKit'
    pod 'lottie-ios'
    pod 'Firebase/Messaging'
    pod 'FacebookSDK'
    pod 'URLEmbeddedView'
    pod 'FacebookShare'
end


target 'Common' do 
	project 'Common/Common.xcodeproj'
	
	target 'CommonTests' do 
	inherit! :search_paths
	
	
	end
end

target 'Networking' do
	project 'Networking/Networking.xcodeproj'
	networking_pods        


	target 'NetworkingTests' do 
	inherit! :search_paths
	
	end
end


target 'PantauBersama' do
	project 'PantauBersama/PantauBersama.xcodeproj'
	application_pods
	application_rx
	networking_pods

	target 'PantauBersamaTests'
	inherit! :search_paths do
	

	end	
end


