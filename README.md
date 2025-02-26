# digitaleye

A camera app to quickly apply common filters for artists and colorblind. This enables them to quickly check values and colors without extra submenus causing hassle.

## Running

Currently this is just a flutter app. Run with:
```
flutter run
```

## Features

| Feature    | Implemented |
| -------- | ------- |
| Saturation  | :heavy_check_mark:    |
| Posterize | :heavy_check_mark:     |
| Steps / Notan | :heavy_check_mark:|
| Contrast    | :heavy_check_mark:|
| Brightness    | :heavy_check_mark:|
| Exposure    | :heavy_multiplication_x:|
| ColorPicker    | :heavy_check_mark:|
| ColorPickerArea    | :heavy_check_mark:|
| ColorPickerSmartArea | :heavy_multiplication_x:|
| ColorPickerSmartScreen | :heavy_multiplication_x:|
| CaptureImage | :heavy_check_mark:|
| CaptureWithFilters | :heavy_check_mark:|
| Horizontal Flip | :heavy_check_mark:|
| Vertical Flip | :heavy_check_mark:|
| Blur | :heavy_check_mark: |
| Image Select | :heavy_check_mark:|
| Color Palettes | :heavy_multiplication_x:|
| Reset | :heavy_check_mark:|


## Known Issues
-Currently not working with new impeller renderer.

-ndk version mismatch

-The gallery opens to an error on some Android/Samsung devices due to Gal.open() bug

