// USAGE: Use in FIJI
//
// Author: Marnie L Maddock (University of Wollongong)
// mmaddock@uow.edu.au, mlm715@uowmail.edu.au
// 23.04.2026
/* Copyright 2024 Marnie Maddock

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), 
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * Instructions
 *  Use for .tif images
 *  Images that have no cells (all black for example, will have the error: No window with "Results" found. Remove this black image from the dataset.
	Press run
	
*/

//run("Close All");
roiManager("reset");
roiManager("Show None");

// Get source directory from user
dir1 = getDirectory("Choose Source Directory of binary images");

// Create directories for saving results
resultsDir = dir1+"CSV_results/";
resultsDir2 = dir1+"ROI_images/";
File.makeDirectory(resultsDir);
File.makeDirectory(resultsDir2);
dir2 = resultsDir;
dir3 = resultsDir2;
// List all files in the source directory
list = getFileList(dir1);

//Saving the wrong ROI on the image
//Check ROI's saving
//CHeck that skeleton is added to correct AP Image results

// Show a dialog to remind the user to check the scale
Dialog.create("Reminder");
Dialog.addMessage("Please check that the image scale is set correctly before proceeding to ensure measurements are in the right units. This can be done by checking the header of an inserted image.");
Dialog.addCheckbox("The image scale is correct", false);
Dialog.show();

scaleChecked = Dialog.getCheckbox();

if (!scaleChecked) {
    showMessage("Scale Check", "The macro will now exit. Please check the image scale and run the macro again use Analyze --> Set Scale....");
    exit(); // Exit the macro if the user does not confirm that the scale is correct
}

processFolder(dir1);
function processFolder(dir1) {
    list = getFileList(dir1);
    list = Array.sort(list);
    for (i = 0; i < list.length; i++) {
        if (endsWith(list[i], ".tif")) {
            processFile(dir1, dir2, list[i]);
        }
    }
} 	 

function processFile(dir1, dir2, file){
	open(dir1 + File.separator + file);
	//run("Set Scale...", "distance=6 known=1.47 unit=micron global");
		title2 = getTitle();
		run("Duplicate...", " ");
		title4 = getTitle();
		selectWindow(title2);
			run("Skeletonize");
			run("Analyze Skeleton (2D/3D)", "prune=none calculate display");
			title3 = getTitle;
			selectWindow(title3);

			// Keep Skeleton Results
		IJ.renameResults("Skeleton results");
		wait(1000);
		saveAs("Results", dir2 + "skeleton_" + title2 +".csv"); 
		//wait(2000);
		wait(1000);
		//Insert code by Volko
		run("Select All");
		getStatistics(area, mean, min, max, std, histogram);
		
		for (b = 1; b < max+1; b++) {
		 setThreshold(b-0.5 , b+0.5);
		 run("Create Selection");
		 roiManager("Add");
		}

		roiManager("Show All with labels");
		//selectWindow("ROI Manager");
		wait(500);
		roiManager("Save", dir3 + "Skeleton_ROI_" + title2 + ".zip"); 
		selectWindow(title3);
		saveAs("Tiff", dir3 + "Skeleton_image_" + title2 + ".tif");

		print(title2);

		selectWindow(title4);

			//ANalyze particles (do not exclude edges)
			run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction limit display add redirect=None decimal=8");
			run("Analyze Particles...", "  show=[Count Masks] display clear summarize add");
			wait(500);
	
			selectWindow("Skeleton_image_" + title2 + ".tif");
		y = roiManager("count");
		skeletonIDs = newArray(y);
		for(p=0; p<y; p++){
			roiManager("select", p);
			getStatistics(area, mean, min, max);
			skeletonIDs[p] = max;
		}


		selectWindow("Results");
		Table.setColumn( "Skeleton ID", skeletonIDs);
		Table.update;
		wait(50);

		saveAs("Results", dir2 + "AP_" + title2 +".csv");
		selectWindow(title4);
		roiManager("Save", dir3 + "AP_ROI_" + title2 + ".zip"); 
		saveAs("Tiff", dir3 + "AP_image_" + title2 + ".tif");
		close("Tagged skeleton");
		close("Longest shortest paths");
		close("AP_image_" + title2 + ".tif");
		close("AP_"  + title2 + ".csv"); 
		close("Skeleton_image_" + title2 + ".tif");
		close("Count Masks of " + title4);
		close(title2);
		close("skeleton_" + title2 + ".csv");
roiManager("reset");
roiManager("Show None");
close("*");
		//close("skeleton_" + title2 + ".csv");
}
close("*");
close("Branch information");
close("Results");
close("Summary");
exit("Done");
