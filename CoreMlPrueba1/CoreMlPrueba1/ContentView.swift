//
//  ContentView.swift
//  CoreMLSwiftUIApp
//
import SwiftUI
import CoreML

/// Estructura principal de la aplicación.
@main
struct CoreMLSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// La vista principal de la aplicación.
/// Muestra una imagen, un resultado de reconocimiento y un botón para seleccionar fotos.
struct ContentView: View {
    // Variables de estado para la UI. Cuando cambian, la vista se actualiza automáticamente.
    @State private var selectedImage: UIImage?
    @State private var recognizedText: String = "Selecciona una imagen"
    @State private var isShowingImagePicker: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 1. Vista para mostrar la imagen seleccionada.
                // Usa un `if` para mostrar la imagen real o un icono de placeholder.
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .cornerRadius(10)
                        .onTapGesture {
                            self.isShowingImagePicker = true
                        }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            self.isShowingImagePicker = true
                        }
                }

                // 2. Etiqueta para mostrar el resultado de la predicción.
                Text(recognizedText)
                    .font(.title2)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationTitle("Reconocimiento Core ML")
        }
        // 3. Muestra el selector de fotos (`UIImagePickerController`) como una hoja modal.
        .sheet(isPresented: $isShowingImagePicker) {
            // El `ImagePicker` es un envoltorio de SwiftUI para la vista de UIKit.
            ImagePicker(selectedImage: self.$selectedImage)
                .onDisappear {
                    // Cuando el selector se cierra, analizamos la imagen.
                    if selectedImage != nil {
                        self.analyzeImage()
                    }
                }
        }
    }

    private func analyzeImage() {
           guard let image = selectedImage else {
               recognizedText = "No se pudo cargar la imagen"
               return
           }

           // Convertir la UIImage a un CVPixelBuffer con el tamaño correcto para MobileNetV2 (224x224).
           guard let pixelBuffer = image.toCVPixelBuffer(size: CGSize(width: 224, height: 224)) else {
               recognizedText = "❌ No se pudo convertir a CVPixelBuffer"
               return
           }

           do {
               // 4. Cargar el modelo MobileNetV2.
               let config = MLModelConfiguration()
               let model = try MobileNetV2(configuration: config)

               let input = MobileNetV2Input(image: pixelBuffer)
               let output = try model.prediction(input: input)

               // Obtiene el resultado principal (la etiqueta con mayor probabilidad).
               let topResult = output.classLabel
               
               // Accede a todas las probabilidades para cada clase.
               let allProbs = output.classLabelProbs
               
               //  Filtrar y ordenar las 4 probabilidades más altas.
               let top4Results = allProbs.sorted { $0.value > $1.value }.prefix(4)
               
               // Formatea el texto para mostrarlo en la UI.
               var resultsText = "Resultado Principal: \(topResult)\n\n"
               resultsText += "Top 4 Predicciones:\n"
               
               for (index, (label, prob)) in top4Results.enumerated() {
                   // Formatea la probabilidad como un porcentaje.
                   let percentage = String(format: "%.2f%%", prob * 100)
                   resultsText += "\(index + 1). \(label) (\(percentage))\n"
               }
               
               self.recognizedText = resultsText

           } catch {
               self.recognizedText = "❌ Error al predecir: \(error.localizedDescription)"
           }
       }
   }

/// Un `UIViewControllerRepresentable` que actúa como un puente
/// para usar `UIImagePickerController` (de UIKit) en SwiftUI.
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // El coordinador es el delegado del `UIImagePickerController`.
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

/// Una extensión para `UIImage` para facilitar la conversión a `CVPixelBuffer`.
extension UIImage {
    func toCVPixelBuffer(size: CGSize) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)

        guard status == kCVReturnSuccess else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
