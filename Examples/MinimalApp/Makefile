SCHEME := MinimalAppScreenshots
IPHONE := platform=iOS Simulator,name=iPhone 17 Pro Max
IPAD := platform=iOS Simulator,name=iPad Pro 13-inch (M5)

.PHONY: screenshots iphone ipad

screenshots: iphone ipad

iphone: MinimalApp.xcodeproj
	xcodebuild test -project $< -scheme $(SCHEME) -destination "$(IPHONE)"

ipad: MinimalApp.xcodeproj
	xcodebuild test -project $< -scheme $(SCHEME) -destination "$(IPAD)"

MinimalApp.xcodeproj: project.yml
	xcodegen generate
