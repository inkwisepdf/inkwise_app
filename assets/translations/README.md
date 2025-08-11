# Translations Directory

This directory contains translation files for the Inkwise PDF app interface.

## Translation Files

### JSON Format
Translation files are stored in JSON format with the following structure:

```json
{
  "app_name": "Inkwise PDF",
  "home": {
    "title": "Home",
    "welcome": "Welcome to Inkwise PDF"
  },
  "tools": {
    "merge": "Merge PDFs",
    "split": "Split PDF",
    "compress": "Compress PDF"
  }
}
```

### Supported Languages
- `en.json` - English (default)
- `es.json` - Spanish
- `fr.json` - French
- `de.json` - German
- `it.json` - Italian
- `pt.json` - Portuguese
- `ru.json` - Russian
- `zh.json` - Chinese
- `ja.json` - Japanese
- `ko.json` - Korean
- `ar.json` - Arabic
- `hi.json` - Hindi

## Usage

The app automatically loads the appropriate translation file based on the user's language preference. If a translation is missing, it falls back to English.

## Adding New Languages

To add support for a new language:

1. Create a new JSON file with the language code (e.g., `nl.json` for Dutch)
2. Translate all the keys from `en.json`
3. Update the language selection in the app settings
4. Test the translation thoroughly

## Translation Guidelines

- Keep translations concise and clear
- Maintain consistent terminology across the app
- Consider cultural differences in UI/UX
- Test translations with native speakers when possible