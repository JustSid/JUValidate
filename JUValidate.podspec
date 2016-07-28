Pod::Spec.new do |spec|

	spec.name = 'JUValidate'
	spec.version = '0.9.1'
	spec.summary = 'Object graph validation library'
	spec.homepage = 'http://github.com/JustSid/JUValidate'
	spec.authors = { 'Sidney Just' => 'justsid@widerwille.com' }
	spec.license = { :type => 'MIT' }
	spec.source = { :git => 'https://github.com/JustSid/JUValidate.git', :tag => "v#{spec.version}" }
	spec.requires_arc = true
	spec.platforms = { :ios => '8.0', :osx => '10.10' }
	spec.source_files = [ 'JUValidate/Source/JU*.{h,m}' ]
	spec.private_header_files = [ 'JUValidate/Source/JULogicValidator.h', 'JUValidate/Source/JUBlockValidator.h' ]

end
