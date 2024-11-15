// Checking for compatible image
if (nSlices() == 0 || getWidth() == 0 || getHeight() == 0) {
    showMessage("Error", "Invalid image. Please open a valid image before running the macro.");
    exit();
}

// Activate the oval selection tool and wait for user input
setTool("oval"); 

//Checking for valid input
if (selectionType() == -1) {
    showMessage("Error", "No region selected. Please select the plate area before proceeding.");
    exit();
}

// Convert image to 8-bit for faster processing and smoother analysis
run("8-bit");

// Prompt user to select the plate area
waitForUser("Select the plate area containing colonies for counting, then click 'OK' to proceed.");


// Clear the area outside the selected plate
setBackgroundColor(0, 0, 0); // Set background to black
run("Clear Outside");

// Enable auto-thresholding and allow user adjustment
setAutoThreshold("Default dark no-reset");
run("Threshold...");  
waitForUser("Adjust the threshold to highlight ONLY the colonies in red, then click 'OK' to proceed.");
setOption("BlackBackground", true); // Set black as the background for binary operations

// Convert image to binary and apply watershed to separate connected colonies
run("Convert to Mask");
run("Watershed");

// Get the minimum colony size from the user with validation
validInput = false;
while (!validInput) {
    minSize = getNumber("Enter the minimum colony size (in pixels). This roughly equals the diameter of a colony as measured using the line tool:", 100);
    if (minSize > 0) {
        validInput = true;
    } else {
        showMessage("Invalid input", "Please enter a positive number for the colony size.");
    }
}
// ensure value is input 
if (isNaN(minSize) || minSize <= 0) {
    showMessage("Error", "Operation cancelled or invalid input. Exiting...");
    exit();
}

// Analyze particles to count colonies and display additional details
run("Analyze Particles...", "size=" + minSize + "-Infinity display exclude clear summarize add");
