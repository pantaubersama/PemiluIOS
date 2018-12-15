platform :ios, '10.0'
use_frameworks!

workspace 'PantauBersama'

project 'PantauBersama/PantauBersama.xcodeproj'
project 'Common/Common.xcodeproj'

def application_pods


end

target 'Common' do 
	project 'Common/Common.xcodeproj'
	
	target 'CommonTests' do 
	inherit! :search_paths

	end
end

target 'Networking' do
	project 'Networking/Networking.xcodeproj'
        
	target 'NetworkingTests' do 
	inherit! :search_paths

	end
end


target 'PantauBersama' do
	project 'PantauBersama/PantauBersama.xcodeproj'
	
	target 'PantauBersamaTests'
	inherit! :search_paths do

	end	
end


post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
        end
    end
end


