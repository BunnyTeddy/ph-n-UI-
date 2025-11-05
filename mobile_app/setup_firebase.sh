#!/bin/bash

# 🔥 Firebase Setup Script for Plant Care App
# Chạy script này để setup Firebase tự động

echo "🔥 Starting Firebase setup..."
echo ""

# Step 1: Check if FlutterFire CLI is installed
echo "📦 Step 1: Checking FlutterFire CLI..."
if ! command -v flutterfire &> /dev/null
then
    echo "⚠️  FlutterFire CLI not found. Installing..."
    dart pub global activate flutterfire_cli
    
    # Add to PATH
    export PATH="$PATH":"$HOME/.pub-cache/bin"
    echo "✅ FlutterFire CLI installed!"
else
    echo "✅ FlutterFire CLI already installed"
fi
echo ""

# Step 2: Check Firebase login
echo "🔐 Step 2: Checking Firebase login..."
if ! firebase projects:list &> /dev/null
then
    echo "⚠️  Not logged in to Firebase. Please login:"
    firebase login
else
    echo "✅ Already logged in to Firebase"
fi
echo ""

# Step 3: Run flutterfire configure
echo "⚙️  Step 3: Configuring Firebase for Flutter..."
echo "Select the Firebase project that Hiệp created"
echo ""
flutterfire configure

# Check if firebase_options.dart was created
if [ -f "lib/firebase_options.dart" ]; then
    echo ""
    echo "✅ firebase_options.dart created successfully!"
else
    echo ""
    echo "❌ firebase_options.dart was not created. Please check errors above."
    exit 1
fi

# Step 4: Flutter pub get
echo ""
echo "📦 Step 4: Installing Flutter dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully!"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Done
echo ""
echo "============================================"
echo "🎉 Firebase setup complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Run 'flutter run' to test the app"
echo "2. Check console for '✅ Firebase initialized successfully!'"
echo "3. Test authentication features"
echo ""
echo "If you see errors, check FIREBASE_SETUP_GUIDE.md"
echo ""


