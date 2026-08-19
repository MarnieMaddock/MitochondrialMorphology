// USAGE: Use in FIJI
//
// Author: Marnie L Maddock (University of Wollongong)
// mmaddock@uow.edu.au, mlm715@uowmail.edu.au
// 23.04.2026
/* Copyright 2026 Marnie Maddock

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), 
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * Instructions
 *  Use for .tif images. Press run
*/

// Select the folder containing the original .tif images
dir1 = getDirectory("Choose Source Directory of original images");
// Create output folders
resultsDir = dir1+"Binary_images/";
File.makeDirectory(resultsDir);
dir2 = resultsDir
dir3 = resultsDir + "ThresholdPreview/"
File.makeDirectory(dir3);


// Ask user which channel is the mitochondrial channel
Dialog.create("Mitochondria Channel");
Dialog.addChoice("Select mito channel:", newArray("C1", "C2", "C3", "C4", "C5"), "C1");
Dialog.show();
mitoChoice = Dialog.getChoice();

// Extract the channel number from the selected channel (e.g. "C1" -> "1")
mitoChannel = substring(mitoChoice, 1);

// Allow the user to enter the optimised mitochondrial segmentation parameters
function setParameters() {
    // Create a dialog to get user input
    Dialog.create("Set Parameters for 3D Threshold");

    // Add message with help text
    Dialog.addMessage("Enter the parameters identified using Mitochondria Analyzer > 2D > 2D Threshold Optimize.");

    // Add numeric fields for each parameter
    Dialog.addNumber("Rolling (microns)", 1.25);
    Dialog.addNumber("Sigma radius", 0.50);
    Dialog.addNumber("Adjust gamma", 0.80);
    Dialog.addNumber("Block size (microns)", 2.05);
    Dialog.addNumber("C-value", 4);
    Dialog.addNumber("Outlier radius (Pixels)", 0.5);

	// Add drop-down menu for method
    methods = newArray("Mean", "Median", "MidGrey", "[Weighted Mean]");
    Dialog.addChoice("Method", methods, "[Weighted Mean]");
    
    // Show the dialog and get the user input
    Dialog.show();

    // Retrieve the values entered by the user
    params = newArray(7);
    params[0] = Dialog.getNumber();
    params[1] = Dialog.getNumber();
    params[2] = Dialog.getNumber();
    params[3] = Dialog.getNumber();
    params[4] = Dialog.getNumber();
    params[5] = Dialog.getNumber();
    params[6] = Dialog.getChoice();
    
    return params;
}

// Apply the Mitochondria Analyzer 3D Threshold command
// using the parameters selected by the user
function apply3DThreshold(params) {
    command = "subtract rolling=" + params[0] + " sigma radius=" + params[1] + 
              " enhance max=1.40 scale_0=2.600 from=0.50 to=0.80" +
              " adjust gamma=" + params[2] + " method=" + params[6] + " block=" + 
              params[3] + " c-value=" + params[4] + " despeckle remove fill outlier=" + params[5] + " show";
    run("3D Threshold", command);
}

// Ask the user to enter the optimised segmentation parameters once
// These settings will then be applied to all images in the dataset
parameters = setParameters();

// Create log text
logText = "";
var logText = "";
// Timestamp
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
logText += "Mitochondria Segmentation Macro Log\n";
logText += "----------------------------------\n";
logText += "Date: " + year + "-" + (month+1) + "-" + dayOfMonth + "\n";
logText += "Time: " + hour + ":" + minute + ":" + second + "\n\n";
logText += "Source directory: " + dir1 + "\n";
logText += "Binary output directory: " + dir2 + "\n";
logText += "Selected mito channel: C" + mitoChannel + "\n\n";
logText += "3D Threshold Parameters\n";
logText += "-----------------------\n";
logText += "Rolling (microns): " + parameters[0] + "\n";
logText += "Sigma radius: " + parameters[1] + "\n";
logText += "Adjust gamma: " + parameters[2] + "\n";
logText += "Block size (microns): " + parameters[3] + "\n";
logText += "C-value: " + parameters[4] + "\n";
logText += "Outlier radius (pixels): " + parameters[5] + "\n";
logText += "Method: " + parameters[6] + "\n\n";

// Batch process all TIFF images in the selected source directory
processFolder(dir1);

logText += "\nProcessing complete.\n";

// Save the processing log in the binary image output folder
logFile = dir2 + "MitoSegmentation_Log.txt";
File.saveString(logText, logFile);

exit("Done");

// Identify and process each TIFF image in the source directory
function processFolder(dir1) {
    list = getFileList(dir1);
    list = Array.sort(list);
    for (i = 0; i < list.length; i++) {
    	fileLower = toLowerCase(list[i]);
         if (endsWith(fileLower, ".tif") || endsWith(fileLower, ".tiff")) {
            processFile(dir1, dir2, list[i]);
        }
    }
} 


// Process a single TIFF image		
function processFile(dir1, dir2, file){
	open(dir1 + File.separator + file);
	print(dir1 + File.separator + file);
	
	// Record the original image title and dimensions	
	title = getTitle();
	getDimensions(width, height, channels, slices, frames);
	
	// Isolate the mitochondrial channel
	if (channels > 1) {

	    run("Split Channels");
		// Build expected mito channel window name, e.g. "C2-myimage.tif"
	    mitoWindow = "C" + mitoChannel + "-" + title;
	
		// Select chosen mito channel and rename to Mito
	    if (isOpen(mitoWindow)) {
	        selectWindow(mitoWindow);
	        rename("Mito");
	    } else {
	        print("Could not find expected channel window: " + mitoWindow);
	        close("*");
	        return;
	    }
	
	    // Close other channels
	    for (c = 1; c <= channels; c++) {
	        otherWindow = "C" + c + "-" + title;
	        if (c != parseInt(mitoChannel) && isOpen(otherWindow)) {
	            selectWindow(otherWindow);
	            close();
	        }
	    }
	
	} else {
	
	    // Single-channel image: no splitting needed
	    rename("Mito");
	}

	// Check if image is RGB, then convert to 8-bit
	if (bitDepth() == 24) {
	    run("8-bit");
	}

	 // Apply the user-defined mitochondrial segmentation parameters
	apply3DThreshold(parameters);
		
	// Remove existing file extension
	baseTitle = title;
	
	if (endsWith(baseTitle, ".tif")) {
	    baseTitle = substring(baseTitle, 0, lengthOf(baseTitle) - 4);
	} else if (endsWith(baseTitle, ".tiff")) {
	    baseTitle = substring(baseTitle, 0, lengthOf(baseTitle) - 5);
	}
	
	 // Save the original-versus-thresholded comparison image for quality control
    if (isOpen("Mito thresholded_COMPARISON")) {
        selectWindow("Mito thresholded_COMPARISON");
        saveAs("TIFF", dir3 + "ThresholdPreview_" + baseTitle + ".tif");
        close();
    }
    
    // Close the original mitochondrial image once thresholding is complete
    if (isOpen("Mito")) {
        selectWindow("Mito");
        close();
    }


    // Select the thresholded mitochondrial image
    if (!isOpen("Mito thresholded")) {
        print("WARNING: Thresholded image not generated for " + title);
        logText += "FAILED: " + title +
                   " - thresholded image not generated\n";
        return;
    }
	selectWindow("Mito thresholded");

	
	// Check whether segmentation contains any foreground pixels
	getHistogram(values, counts, 256);
	
	foregroundPixels = 0;
	for (h = 1; h < 256; h++) {
	    foregroundPixels += counts[h];
	}
	
	if (foregroundPixels == 0) {
	    print("WARNING: No mitochondria detected in " + title);
	    logText += "FAILED: " + title + " - no foreground pixels detected\n";
	
	    close("Mito thresholded");
	    if (isOpen("Mito thresholded_COMPARISON")) {
	        close("Mito thresholded_COMPARISON");
	    }
	    if (isOpen("Mito")) {
	        close("Mito");
	    }
	
	    return;
	}
	
	// Separate Z-stacks into individual binary image planes
	getDimensions(width, height, channels, slices, frames);
	if (slices > 1) {
	    run("Stack to Images");
	} 
	 // Save each binary mitochondrial image for downstream morphology analysis
	for (j = nImages; j > 0; j--){
		if (is( "binary" )) {
				saveAs("TIFF", dir2 + "Binary_" + baseTitle + j + ".tif"); 
				close();
			}
	}	
}

