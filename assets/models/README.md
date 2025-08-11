# AI Models Directory

This directory contains the offline AI models used by Inkwise PDF for various features.

## Model Files

### Summarization Models
- `summarizer_model.tflite` - TensorFlow Lite model for PDF summarization
- `vocab.txt` - Vocabulary file for the summarization model

### Translation Models
- `translation_model.tflite` - TensorFlow Lite model for offline translation
- `translation_vocab.json` - Vocabulary and language mappings

### OCR Models
- Tesseract data files for various languages
- Custom trained models for better accuracy

### Computer Vision Models
- Form detection models
- Table extraction models
- Image cleanup models

## Model Sources

These models are trained on publicly available datasets and optimized for mobile deployment. They provide offline capabilities for:

1. **Text Summarization** - Extract key points from documents
2. **Language Translation** - Translate between multiple languages
3. **Form Detection** - Identify fillable areas in scanned documents
4. **Table Extraction** - Convert PDF tables to editable format
5. **Image Processing** - Clean up and enhance document images

## Usage

Models are automatically loaded by the respective services when needed. The app will download and cache models on first use to ensure offline functionality.

## Model Updates

Models can be updated through the app's settings or by downloading new versions from the official repository.