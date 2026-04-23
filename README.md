# MitochondrialMorphology
FIJI (ImageJ) Macros to obtain Mito Morphology measurements. The macro is split into two parts. Part 1 makes mitochondrial images binary, and part 2 extracts area/perimeter/branch point etc measurements from each mitochondria and saaves each imag results as a csv.

## How It Works

1. **Folder of TIFF Images**: All images need to be saved as a TIFF in a folder on your computer. To automatically convert .lif files to TIFF, see https://github.com/MarnieMaddock/Lif-to-Tif.
2. **Add Adaptive Threshold Plugin**: Install Adaptive Threshold Plugin using instructions given here: https://sites.google.com/site/qingzongtseng/adaptivethreshold. Ensure when naming the plugin use adaptiveThr (check capitalisation)
3. **Open macro in FIJI**: Drag and MitoMorph_MakeBinary_Adaptive_1.ijm into the FIJI console.
4. **Run**: Press Run on the macro.
5. **Customise Analysis**: The macro will ask to select the folder containing TIFF images to be analysed. A pop-up box will appear to guide users into specifying the channels that correspond to the mitochondria. The macro will prompt the user to specify the pre-processing filters and settings they prefer. Use the thresholdOptimize function to optimise parameters.
6. **Save Binary Images**: Binary images will be saved in the Binary_images folder.
7. **Pause**: The macro is purposely broken into two parts, so you can go and check the thresholding accuracy of the segmented mitochondria (ThresholdPreview), so poorly segmented images (due to being out of focus etc) can be removed before extracting measurement data.
8. **Run**: Open part 2 (Drag and drop MitoMorph_Analyze_2.ijm into FIJI) and press run.
9. **Select Binary_Images Folder**: Select the binary images folder and per mitochondria measurements will be extracted.
10. **Output**:  Per mitochondria results are saved as a .csv file. Regions of interest are saved to the ROI_images folder. 


## Feedback and Support
If you encounter any issues or have suggestions, feel free to:

- Open an issue on this repository
- [Email Us](mlm715@uowmail.edu.au)

  
## License
MitochondrialMorphology project is licensed under the MIT License. See [LICENSE](https://github.com/MarnieMaddock/MitochondrialMorphology/blob/main/LICENSE) for details.

---- 
