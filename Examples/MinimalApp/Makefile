SCHEME := MinimalAppScreenshots

.PHONY: screenshots iphone-pro-max iphone ipad

screenshots: iphone-pro-max iphone ipad

iphone-pro-max: NAME := iPhone 17 Pro Max
iphone: NAME := iPhone 17
ipad: NAME := iPad Pro 13-inch (M5)
iphone-pro-max iphone ipad: MinimalApp.xcodeproj
	xcodebuild test -project $< -scheme $(SCHEME) -destination "platform=iOS Simulator,name=$(NAME)"

MinimalApp.xcodeproj: project.yml
	xcodegen generate
