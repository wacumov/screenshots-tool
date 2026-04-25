SCHEME := MinimalAppScreenshots
DESTINATION ?= platform=iOS Simulator,name=iPhone 17 Pro

.PHONY: screenshots
screenshots: MinimalApp.xcodeproj
	xcodebuild test -project $< -scheme $(SCHEME) -destination "$(DESTINATION)"

MinimalApp.xcodeproj: project.yml
	xcodegen generate
