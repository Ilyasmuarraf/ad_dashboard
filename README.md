========================================================================
AD CAMPAIGN DASHBOARD — PRODUCTION RUN INSTRUCTIONS
========================================================================

Thank you for reviewing my submission! This folder contains everything 
needed to evaluate the Ad Campaigns Dashboard application. 

Inside this folder, you will find:
1. app-release.apk  -> For immediate testing on an Android device.
2. ad_dashboard.zip -> The complete, clean Flutter source code.

Below are the step-by-step instructions for both quick testing and full 
local code execution.

------------------------------------------------------------------------
METHOD 1: QUICK TESTING (Using the APK)
------------------------------------------------------------------------
If you simply want to test the working application on an Android device or 
emulator without compiling the code:

1. Download the "app-release.apk" file from this folder.
2. Transfer it to an Android device (or drag-and-drop it onto an active Android Emulator).
3. Install the APK (enable "Install from Unknown Sources" if prompted by Android).
4. Launch the "AdOps Dashboard" app from your app drawer.

*Note: This is a fully optimized production release build.*

------------------------------------------------------------------------
METHOD 2: CODE REVIEW & LOCAL EXECUTION (Using the ZIP)
------------------------------------------------------------------------
To open, inspect, and run the source code on your local development machine:

1. Environment Prerequisites:
   - Flutter SDK: ^3.19.0 (Stable Channel)
   - Java Development Kit: JDK 17 (Required for Kotlin Script execution)
   - Target: Android Emulator, Physical Device, or Chrome Web Browser

2. Step-by-Step Setup:
   a. Download and extract "ad_dashboard.zip".
   b. Open your terminal, navigate into the extracted directory:
      cd ad_dashboard
   c. Fetch all required package dependencies (Riverpod, fl_chart, etc.):
      flutter pub get
   d. Clear any localized build caching and rebuild the dependency tree:
      flutter clean
      flutter pub get

3. Running the Project:
   - To launch the app in standard debug mode with hot-reload enabled:
     flutter run
   - To run specifically on a web browser layout:
     flutter run -d chrome

4. Running Automated Tests:
   - To execute the automated widget and navigation state test suite:
     flutter test

------------------------------------------------------------------------
ARCHITECTURAL HIGHLIGHTS FOR EVALUATION
------------------------------------------------------------------------
- State Management: Handled purely via Riverpod 2.x using FutureProvider.family 
  and StreamProvider streams to eliminate logic from the UI layer.
- Zero Hardcoded Math: All progress tracking layouts, chart ratios, and data 
  legends are parsed and computed dynamically from live network data models.
- Navigation Shell: Implements an IndexedStack wrapper to preserve stream 
  positions and application state flawlessly across bottom navigation tab switches.
- Theme System: Fully supports system-level adaptive Light and Dark theme modes.
- Animations: Smooth shared-element Hero animations linking the dashboard 
  list cleanly to the detailed metric analysis views.
========================================================================
