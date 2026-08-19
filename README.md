# Mitochondrial Morphology
FIJI (ImageJ) Macros to obtain Mito Morphology measurements. The macro is split into two parts. Part 1 makes mitochondrial images binary, and part 2 extracts area/perimeter/branch point etc measurements from each mitochondria and saves each image's results as a csv.

## How It Works

1. **Folder of TIFF Images**: All images need to be saved as a TIFF in a folder on your computer. To automatically convert .lif files to TIFF, see https://github.com/MarnieMaddock/Lif-to-Tif.
2. **Add Plugins**: Install Adaptive Threshold Plugin using the instructions given here: https://sites.google.com/site/qingzongtseng/adaptivethreshold. Ensure when naming the plugin use adaptiveThr (check capitalisation). Also install the Mitochondrial Analyzer plugin https://github.com/AhsenChaudhry/Mitochondria-Analyzer. Note, these plugins are only compatible with an older version of FIJI with Java 8, not the latest release (Java 21). Please download the `stable` version of FIJI with Java 8 https://imagej.net/software/fiji/downloads.
3. **Open macro in FIJI**: Drag and MitoMorph_MakeBinary_Adaptive_1.ijm into the FIJI console.
4. **Run**: Press Run on the macro.
5. **Customise Analysis**: The macro will ask to select the folder containing TIFF images to be analysed. A pop-up box will appear to guide users into specifying the channels that correspond to the mitochondria. The macro will prompt the user to specify the pre-processing filters and settings they prefer. Use the thresholdOptimize function to optimise parameters.
6. **Save Binary Images**: Binary images will be saved in the Binary_images folder.
7. **Pause**: The macro is purposely broken into two parts, so you can go and check the thresholding accuracy of the segmented mitochondria (ThresholdPreview), so poorly segmented images (due to being out of focus etc) can be removed before extracting measurement data.
8. **Run**: Open part 2 (Drag and drop MitoMorph_Analyze_2.ijm into FIJI) and press run.
9. **Select Binary_Images Folder**: Select the binary images folder and per mitochondria measurements will be extracted.
10. **Output**:  Per mitochondria results are saved as a .csv file. Regions of interest are saved to the ROI_images folder. 

<img width="4651" height="5187" alt="mitomorph_methods" src="https://github.com/user-attachments/assets/8aa10009-2806-43e8-aae7-6dba05f2483d" />

## Software Requirements
FIJI/ImageJ with Java 8. The plugins required by the image-analysis pipeline are not currently compatible with the latest Java 21 release of FIJI. Download FIJI Stable Release. https://imagej.net/software/fiji/downloads 
- Required Version: ImageJ 1.54p, Java 1.8.0_322 or 1.8.0_452 (64-bit)

## Threshold Optimisation - Before you Start

Mitochondria are segmented from the calibrated .tif images using adaptive thresholding. As fluorescence intensity, background and signal-to-noise can vary between imaging datasets, the thresholding parameters should be optimised for each new dataset before batch segmentation. The 2D Threshold Optimize function in Mitochondria Analyzer allows different thresholding parameters to be tested and compared to identify those that best segment the mitochondria. 

1. Open FIJI
2. Drag and drop a representative mitochondrial image into FIJI
3. Navigate to Plugins -> Mitochondria Analyzer -> 2D -> 2D Threshold Optimize
 <img width="613" height="494" alt="image" src="https://github.com/user-attachments/assets/fcc6b60d-3ee3-49e0-9396-93a9ca309db1" />

4. The 2D Threshold Optimize Window will open. I suggest starting with the following options to test mitochondrial segmentation parameters. 
 <img width="662" height="570" alt="image" src="https://github.com/user-attachments/assets/b8465a7c-630e-469e-a5d7-0bd6f379cbd5" />

5. A montage containing the different thresholding conditions will be generated. Each montage tile contains two channels: the thresholded image and the original fluorescence image. Zoom in on each tile and use the channel slider to switch between the original and thresholded images. Compare the two images to determine which parameter combination most accurately captures the mitochondrial structures.
 <img width="647" height="719" alt="image" src="https://github.com/user-attachments/assets/471e7697-dfad-4c3f-9845-ddbd0bdddbbe" />

6. Record the thresholding parameters associated with the selected tile (i.e. the best block size and c-value). When selecting parameters check that mitochondrial boundaries are retained without excessive loss of signal, artificial fragmentation of individual mitochondria, or merging of neighbouring mitochondria. Ensure that thresholding accurately captures mitochondrial signal without introducing false mitochondrial objects.
7. Test the selected parameters again on approximately five representative images from the dataset to confirm that they produce consistent segmentation across images.
8. Once suitable parameters have been identified, use these settings for batch segmentation of the complete dataset.


## Feedback and Support
If you encounter any issues or have suggestions, feel free to:

- Open an issue on this repository
- [Email Us](mlm715@uowmail.edu.au)

  
## License
MitochondrialMorphology project is licensed under the MIT License. See [LICENSE](https://github.com/MarnieMaddock/MitochondrialMorphology/blob/main/LICENSE) for details.

---- 
