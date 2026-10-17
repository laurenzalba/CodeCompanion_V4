CampusCompanion - Exercise 4 (Programmatic Core Data Model Fix)

This version removes CampusCompanion.xcdatamodeld from the Xcode project because Xcode's Core Data model compiler (momc) was failing while reading that model. The identical CampusAnnouncement entity is now created programmatically in AppDelegate.swift, with String attributes:
title, date, category, priority, postedBy.

Important: open CampusCompanion.xcodeproj from THIS extracted folder, not an older copy. The project should no longer invoke Core Data code generation for a .xcdatamodeld file.

Build steps:
1. Extract this ZIP to a fresh folder.
2. Open CampusCompanion.xcodeproj from this folder.
3. Product > Clean Build Folder (Shift+Command+K).
4. Build (Command+B), then run (Command+R).

If the Simulator contains data from an earlier development build and reports a persistent-store migration error, delete the app from the Simulator and reinstall it. This removes test data stored by that old app copy.

Bundle identifier: edu.feutech.mad2.CampusCompanion
The archive, plist, Storyboard, and project references were checked here. An actual iOS build still must be confirmed using Xcode on macOS.
