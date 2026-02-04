import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../errors/exceptions.dart';

class TfliteService {
  Interpreter? _interpreter;

  // Model input shape (efficientnet-b0 usually 224x224)
  static const int _inputSize = 224;

  // Normalize mean and std for ImageNet (common for transfer learning)
  // Adjust these if your specific training used different normalization
  static const List<double> _mean = [0.485, 0.456, 0.406];
  static const List<double> _std = [0.229, 0.224, 0.225];

  /// Load the TFLite model from assets.
  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions();
      // Use XNNPACK delegate for CPU acceleration if available
      // options.addDelegate(XNNPackDelegate());

      _interpreter = await Interpreter.fromAsset(
        'assets/models/model_optimized.tflite',
        options: options,
      );
      print('TFLite model loaded successfully');
    } catch (e) {
      throw ModelException(message: 'Failed to load model: $e');
    }
  }

  /// Close the interpreter to free resources.
  void close() {
    _interpreter?.close();
  }

  /// Run inference on an image file.
  Future<Map<String, double>> analyzeImage(File imageFile) async {
    if (_interpreter == null) {
      await loadModel();
    }

    try {
      // 1. Read and decode image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw const ModelException(message: 'Failed to decode image');
      }

      // 2. Preprocess image
      final input = _preprocessImage(image);

      // 3. Prepare output buffer
      // Assuming binary classification: [Normal, Pneumonia] or single prob depending on model
      // Let's assume binary output [prob_class_0, prob_class_1] for now
      // Update this based on your actual model structure
      final output = List.filled(1 * 2, 0.0).reshape([1, 2]);

      // 4. Run inference
      _interpreter!.run(input, output);

      // 5. Process results
      final result = output[0] as List<double>;

      // Assuming index 0 = Normal, index 1 = Pneumonia
      // You should verify this mapping with your training notebook
      return {
        'Normal': result[0],
        'Pneumonia': result[1],
      };
    } catch (e) {
      throw ModelException(message: 'Inference failed: $e');
    }
  }

  /// Preprocess image: Resize, Normalize, and convert to Tensor buffer.
  List<dynamic> _preprocessImage(img.Image image) {
    // Resize to model input size
    final resized = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
    );

    // Convert to float32 [1, 224, 224, 3]
    var input = List.generate(
      1,
      (i) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);

            // Normalize RGB values
            final r = (pixel.r / 255.0 - _mean[0]) / _std[0];
            final g = (pixel.g / 255.0 - _mean[1]) / _std[1];
            final b = (pixel.b / 255.0 - _mean[2]) / _std[2];

            return [r, g, b];
          },
        ),
      ),
    );

    return input;
  }
}
