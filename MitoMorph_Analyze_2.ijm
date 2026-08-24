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
 *  Use for .tif images
	Press run
	
*/

// Reset the ROI Manager before processing
roiManager("reset");
roiManager("Show None");

// Select the folder containing the binary mitochondrial images
dir1 = getDirectory("Choose Source Directory of binary images");

// Create output directories for individual CSV results, ROI images,
// and combined summary files for downstream morphology classification
resultsDir = dir1+"CSV_results/";
resultsDir2 = dir1+"ROI_images/";
summaryDir  = dir1 + "Summary_files/";
File.makeDirectory(resultsDir);
File.makeDirectory(resultsDir2);
File.makeDirectory(summaryDir);
dir2 = resultsDir;
dir3 = resultsDir2;

// Extract mitochondrial morphology features from all binary images
processFolder(dir1);
// Combine individual AP and skeleton CSV files into dataset-level summary files
createSummaryFiles(resultsDir, summaryDir);
// End macro after all images have been processed and summary files generated
exit("Done");


// Identify and process each TIFF image in the selected source directory
function processFolder(dir1) {
    list = getFileList(dir1);
    list = Array.sort(list);
    for (i = 0; i < list.length; i++) {
        if (endsWith(list[i], ".tif")) {
            processFile(dir1, dir2, list[i]);
        }
    }
} 	 

// Process a single binary mitochondrial image
function processFile(dir1, dir2, file){
	open(dir1 + File.separator + file);
	// Show a dialog to remind the user to check the scale
  	// Check spatial calibration
    getPixelSize(unit, pixelWidth, pixelHeight, voxelDepth);

    // Print detected calibration to the Log window
    print("Pixel width: " + pixelWidth + " " + unit);
    print("Pixel height: " + pixelHeight + " " + unit);

    // Stop the macro if the image is still calibrated in pixels
    if (unit == "pixel" || unit == "pixels") {

        showMessage(
            "Scale Check",
            "The image is not spatially calibrated.\n\n" +
            "Detected pixel size: " + pixelWidth + " x " +
            pixelHeight + " " + unit + ".\n\n" +
            "Please calibrate the images in micrometres before running this macro.\n" +
            "Use Analyze > Set Scale..."
        );

        exit();
    }
    
    // Confirm that the input image is binary
	if (!is("binary")) {
	    showMessage(
	        "Invalid Input",
	        "The image '" + file + "' is not binary.\n\n" +
	        "Please run the mitochondrial segmentation step before feature extraction."
	    );
	    close();
	    exit();
	}
	
	 // Check whether the binary image contains any foreground pixels
    getHistogram(values, counts, 256);

    foregroundPixels = 0;
	// Sum all non-background pixels
    for (h = 1; h < 256; h++) {
        foregroundPixels += counts[h];
    }

    // Skip empty binary images
    if (foregroundPixels == 0) {
        print("WARNING: No mitochondria detected in " + file);
        close();
        return;
    }
    
	// Store the original image title and create a clean filename for outputs
	title2 = getTitle();
	run("Duplicate...", " ");
	baseTitle = title2;
	if (endsWith(toLowerCase(baseTitle), ".tif")) {
	    baseTitle = substring(baseTitle, 0, lengthOf(baseTitle) - 4);
	}
	// Store the title of the duplicate image used for Analyze Particles
	title4 = getTitle();
	
	// -------------------------------------------------------------------------
	// Skeleton-based feature extraction
	// -------------------------------------------------------------------------
	selectWindow(title2);
	// Skeletonize the original binary mitochondrial image
	run("Skeletonize");
	// Measure branching properties and generate the labelled skeleton image
	run("Analyze Skeleton (2D/3D)", "prune=none calculate display");
	title3 = getTitle();
	selectWindow(title3);

	// Keep Skeleton Results
	IJ.renameResults("Skeleton results");
	wait(1000);
	// Add source image label to each row of the skeleton results	
	nRows = Table.size("Skeleton results");
	
	for (r = 0; r < nRows; r++) {
	    Table.set("Label", r, baseTitle, "Skeleton results");
	}
	
	Table.update("Skeleton results");
	wait(500);
	// Save skeleton-derived measurements
	saveAs("Results", dir2 + "skeleton_" + baseTitle +".csv"); 
	wait(1000);
	
	// Generate an ROI corresponding to each labelled skeleton
	run("Select All");
	getStatistics(area, mean, min, max, std, histogram);
	
	for (b = 1; b < max+1; b++) {
		 setThreshold(b-0.5 , b+0.5);
		 run("Create Selection");
		 roiManager("Add");
	}
	
	// Save skeleton ROIs and labelled skeleton image for quality control
	roiManager("Show All with labels");
	//selectWindow("ROI Manager");
	wait(500);
	roiManager("Save", dir3 + "Skeleton_ROI_" + baseTitle + ".zip"); 
	selectWindow(title3);
	saveAs("Tiff", dir3 + "Skeleton_image_" + baseTitle + ".tif");

	print(title2);

	// -------------------------------------------------------------------------
	// Individual mitochondrial geometric feature extraction
	// -------------------------------------------------------------------------
	// Return to the unmodified duplicate binary image
	selectWindow(title4);

	// Measure geometric properties of each individual mitochondrial object
	// Objects touching the image boundary are retained (exclude edges off)
	run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction limit display add redirect=None decimal=8");
	run("Analyze Particles...", "  show=[Count Masks] display clear summarize add");
	wait(500);
	
	// -------------------------------------------------------------------------
	// Match each mitochondrial object to its corresponding skeleton
	// -------------------------------------------------------------------------
	selectWindow("Skeleton_image_" + baseTitle + ".tif");
	y = roiManager("count");
	skeletonIDs = newArray(y);
	for(p=0; p<y; p++){
		roiManager("select", p);
		getStatistics(area, mean, min, max);
		skeletonIDs[p] = max;
	}

	// Append the corresponding Skeleton ID to each mitochondrial object
	selectWindow("Results");
	Table.setColumn( "Skeleton ID", skeletonIDs);
	Table.update;
	wait(30);
		
	// Calculate elongation as the inverse of circularity
	nRowsAP = nResults;
	
	elongation = newArray(nRowsAP);
	interconnectivity = newArray(nRowsAP);
	
	for (r = 0; r < nRowsAP; r++) {
		 // Elongation = inverse of circularity
	    circ = getResult("Circ.", r);
	
	    if (circ > 0) {
	        elongation[r] = 1 / circ;
	    } else {
	        elongation[r] = NaN;
	    }
	    
	    // Interconnectivity = area divided by perimeter
	    areaValue = getResult("Area", r);
	    perimeterValue = getResult("Perim.", r);
	
	    if (perimeterValue > 0) {
	        interconnectivity[r] = areaValue / perimeterValue;
	    } else {
	        interconnectivity[r] = NaN;
	    }
	}
		
	Table.setColumn("Elongation", elongation);
	Table.setColumn("Interconnectivity", interconnectivity);
	// Remove columns not required for morphology classification
	Table.deleteColumn("Mean");
	Table.deleteColumn("StdDev");
	Table.deleteColumn("Mode");
	Table.deleteColumn("Min");
	Table.deleteColumn("Max");
	Table.deleteColumn("IntDen");
	Table.deleteColumn("RawIntDen");
	Table.deleteColumn("%Area");
	Table.deleteColumn("Median");
	Table.deleteColumn("Skew");
	Table.deleteColumn("Kurt");
	Table.update;
	wait(30);
	
	// -------------------------------------------------------------------------
	// Save individual mitochondrial measurements and quality-control outputs
	// -------------------------------------------------------------------------
	saveAs("Results", dir2 + "AP_" + baseTitle +".csv");
	selectWindow(title4);
	roiManager("Save", dir3 + "AP_ROI_" + baseTitle + ".zip"); 
	saveAs("Tiff", dir3 + "AP_image_" + baseTitle + ".tif");
	close("Tagged skeleton");
	close("Longest shortest paths");
	close("AP_image_" + baseTitle + ".tif");
	close("AP_"  + baseTitle + ".csv"); 
	close("Skeleton_image_" + baseTitle + ".tif");
	close("Count Masks of " + title4);
	close(baseTitle);
	close("skeleton_" + baseTitle + ".csv");
	roiManager("reset");
	roiManager("Show None");
	close("*");
	if (isOpen("Results")) {
	    close("Results");
	}
	
	if (isOpen("Summary")) {
	    close("Summary");
	}
}
// Close any remaining Analyze Skeleton or Results windows
close("*");
// Close any remaining results windows
if (isOpen("Branch information")) {
    close("Branch information");
}

if (isOpen("Results")) {
    close("Results");
}

if (isOpen("Summary")) {
    close("Summary");
}

// Combine all individual AP and Skeleton CSV files into
// two dataset-level summary files for downstream classification
// Combine all individual AP and Skeleton CSV files into
// two dataset-level summary files for downstream classification
function createSummaryFiles(resultsDir, summaryDir) {

    files = getFileList(resultsDir);
    files = Array.sort(files);

    apOutput = summaryDir + "AP_summary.csv";
    skeletonOutput = summaryDir + "Skeleton_summary.csv";

    // Remove old summary files if they already exist
    if (File.exists(apOutput))
        File.delete(apOutput);

    if (File.exists(skeletonOutput))
        File.delete(skeletonOutput);

    apHeaderAdded = false;
    skeletonHeaderAdded = false;

    for (f = 0; f < files.length; f++) {

        fileName = files[f];
        fileLower = toLowerCase(fileName);

        // ---------------------------------------------------------
        // Combine Analyze Particles CSV files
        // ---------------------------------------------------------
        if (startsWith(fileName, "AP_") && endsWith(fileLower, ".csv")) {
			 print("Adding to AP summary: " + fileName);
            text = File.openAsString(resultsDir + fileName);

            if (!apHeaderAdded) {

                // First file: write header + data
                File.saveString(text, apOutput);
                apHeaderAdded = true;

            } else {

                // Subsequent files: remove header and append data
                firstNewline = indexOf(text, "\n");

                if (firstNewline >= 0) {
                    body = substring(text, firstNewline + 1);

                    if (lengthOf(body) > 0)
                        File.append(body, apOutput);
                }
            }
        }

        // ---------------------------------------------------------
        // Combine Skeleton CSV files
        // ---------------------------------------------------------
        if (startsWith(fileName, "skeleton_") && endsWith(fileLower, ".csv")) {
			print("Adding to Skeleton summary: " + fileName);
            text = File.openAsString(resultsDir + fileName);

            if (!skeletonHeaderAdded) {

                // First file: write header + data
                File.saveString(text, skeletonOutput);
                skeletonHeaderAdded = true;

            } else {

                // Subsequent files: remove header and append data
                firstNewline = indexOf(text, "\n");

                if (firstNewline >= 0) {
                    body = substring(text, firstNewline + 1);

                    if (lengthOf(body) > 0)
                        File.append(body, skeletonOutput);
                }
            }
        }
    }

    print("Summary files saved to: " + summaryDir);
}
