SCHEME := MinimalAppScreenshots

.PHONY: screenshots iphone ipad

screenshots: iphone ipad

iphone: NAME := iPhone 17 Pro Max
ipad: NAME := iPad Pro 13-inch (M5)
iphone ipad: MinimalApp.xcodeproj
	xcodebuild test -project $< -scheme $(SCHEME) -destination "platform=iOS Simulator,name=$(NAME)"

MinimalApp.xcodeproj: project.yml
	xcodegen generate
