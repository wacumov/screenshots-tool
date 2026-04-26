SCHEME := MinimalAppScreenshots

.PHONY: screenshots iphone-6.9 iphone-6.3 ipad-13

screenshots: iphone-6.9 iphone-6.3 ipad-13

iphone-6.9: NAME := iPhone 17 Pro Max
iphone-6.3: NAME := iPhone 17
ipad-13: NAME := iPad Pro 13-inch (M5)
iphone-6.9 iphone-6.3 ipad-13: MinimalApp.xcodeproj
	trap "xcrun simctl rename '$@' '$(NAME)' 2>/dev/null" EXIT && \
	xcrun simctl rename '$(NAME)' '$@' && \
	xcodebuild test -project $< -scheme $(SCHEME) -destination "platform=iOS Simulator,name=$@"

MinimalApp.xcodeproj: project.yml
	xcodegen generate
