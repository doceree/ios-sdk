
Pod::Spec.new do |s|

# 1
s.platform = :ios
DocereeAdsSdk = '13.0'
s.name = "DocereeAdsSdk"
s.summary = "Doceree iOS SDK for mobile ads."
s.requires_arc = true

# 2
s.version = "1.0.5"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Muqeem Ahmad" => "muqeem.ahmad@ doceree.com" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/doceree/DocereePodSpecs"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/doceree/DocereePodSpecs.git", 
             :tag => "#{s.version}" }

# 7
s.framework = "UIKit"

# 8
s.source_files = "DocereeAdsSdk/**/*.{swift}"

# 9
s.resources = "DocereeAdsSdk/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "5.0"

end

