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

dir1 = getDirectory("Choose Source Directory of original images");
resultsDir = dir1+"Binary_images/";
File.makeDirectory(resultsDir);
dir2 = resultsDir
dir3 = resultsDir + "ThresholdPreview"
File.makeDirectory(dir3);
list2 = getFileList(dir2);




// Ask user which channel is the mitochondrial channel
Dialog.create("Mitochondria Channel");
Dialog.addChoice("Select mito channel:", newArray("C1", "C2", "C3", "C4"), "C1");
Dialog.show();
mitoChoice = Dialog.getChoice();

// Convert "C1" -> "1", "C2" -> "2", etc.
mitoChannel = substring(mitoChoice, 1);

// Function to set parameters using a dialog box
function setParameters() {
    // Create a dialog to get user input
    Dialog.create("Set Parameters for 3D Threshold");

    // Add message with help text
    Dialog.addMessage("Please go to the Mitochondrial Analyzer to find optimal parameters using Threshold Optimize.");

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
//run("3D Threshold", "subtract rolling=1.25 sigma radius=0.50 adjust gamma=0.90 method=[Weighted Mean] 
//block=2.05 c-value=4 despeckle remove fill outlier=0.5 show");
// Function to apply 3D Threshold with the given parameters
// Function to apply 3D Threshold with the given parameters
function apply3DThreshold(params) {
    command = "subtract rolling=" + params[0] + " sigma radius=" + params[1] + 
              " enhance max=1.40 scale_0=2.600 from=0.50 to=0.80" +
              " adjust gamma=" + params[2] + " method=" + params[6] + " block=" + 
              params[3] + " c-value=" + params[4] + " despeckle remove fill outlier=" + params[5] + " show";
    run("3D Threshold", command);
}

// Set the parameters once
parameters = setParameters();


// Create log text
logText = "";

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


processFolder(dir1);

logText += "\nProcessing complete.\n";


logFile = dir2 + "MitoSegmentation_Log.txt";
File.saveString(logText, logFile);

exit("Done");


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
	print(dir1 + File.separator + file);
	
//Split channels and rename		
		title = getTitle();
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

    // Optional: close other channel windows after splitting
    for (c = 1; c <= 4; c++) {
        otherWindow = "C" + c + "-" + title;
        if (c != parseInt(mitoChannel) && isOpen(otherWindow)) {
            selectWindow(otherWindow);
            close();
        }
    }

		selectWindow("Mito");
		// Create a dialog to get user input

// Run the command
//run("3D Threshold", command);
apply3DThreshold(parameters);
		//run("3D Threshold", "subtract rolling=1.25 sigma radius=0.50 enhance max=1.40 scale_0=2.600 from=0.50 to=0.80 adjust gamma=0.90 method=[Weighted Mean] block=2.05 c-value=4 despeckle remove fill outlier=0.5 show");
		selectWindow("Mito thresholded_COMPARISON");
		saveAs("TIFF", dir3 + "ThresholdPreview_" + title); 
		close("ThresholdPreview_" + title);
		close("Mito");
		selectWindow("Mito thresholded");
		getDimensions(width, height, channels, slices, frames);
		if (slices > 1) {
		    run("Stack to Images");
		}
	

//For all binary images, run extended particle analyzer	
for (j = nImages; j > 0; j--){
	if (is( "binary" )) {
			saveAs("TIFF", dir2 + "Binary_" + title + j + ".tif"); 
			close();
		}
	}	
}
