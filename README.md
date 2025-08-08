# CoreML SwiftUI App

Educational SwiftUI app demonstrating how to integrate **two Core ML models** for object and landscape recognition, used in the **Summer Camp iOS Development Lab 2025** to teach beginners image selection, preprocessing, and prediction display.

## 📚 Educational Context
This code was used in the **Summer Camp iOS Development Lab 2025** to teach beginner students how to:
- Connect a Core ML model with SwiftUI.
- Select images from the photo library.
- Preprocess images for computer vision models.
- Display prediction results clearly in the UI.

## 🚀 Features
- **Image selection** from the gallery using `UIImagePickerController` adapted to SwiftUI.
- **Automatic conversion** from `UIImage` to `CVPixelBuffer` for model input.
- **Core ML integration** with the pre-trained **MobileNetV2** model.
- **Displays the main prediction** and the **top 4 most probable predictions** with percentages.
- **Beginner-friendly UI** designed for educational purposes.

## 🛠 Technologies Used
- **SwiftUI** – For building the user interface.
- **Core ML** – To run machine learning models on-device.
- **MobileNetV2** – Pre-trained image classification model.
- **UIKit bridge** (`UIViewControllerRepresentable`) – To integrate the image picker into SwiftUI.

## 📂 Project Structure
CoreMLSwiftUIApp/
├── ContentView.swift # Main view and prediction logic
├── ImagePicker.swift # SwiftUI adapter for image selection
└── UIImage+PixelBuffer.swift# Extension for UIImage to CVPixelBuffer conversion


## 📸 How It Works
1. Open the app.
2. Tap the image icon to select a photo from your gallery.
3. The app analyzes the image using the model and shows:
   - The main prediction.
   - The top 4 most probable predictions with percentages.

## 📄 License
This project is intended for educational purposes only, as part of the **Summer Camp iOS Development Lab 2025**.

https://drive.google.com/drive/folders/1GAe0xwGxGhdW5j2FionaUPf_PlYsr-Ao 

https://www.canva.com/design/DAGvP01UWjo/nqeJ0qJbr8DRHyXs-ocf7A/edit?utm_content=DAGvP01UWjo&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton 

https://developer.apple.com/machine-learning/models/ 

https://github.com/AfrazCodes/CoreMLDemo-YT/blob/main/CoreMLDemo/GoogLeNetPlaces.mlmodel

https://github.com/twostraws/HackingWithSwift/blob/main/SwiftUI/project4-files/BetterRest.csv 




