//
// Preprocessing part of GECI quant
// Modified by Yizhi for simulation
// remove all user interaction parts and use appropriate settings from data
//
// DO NOT open file in macro; specify it in system call 
//

// Global variables
var MainStack, StackTitle;
var width, height, channels, slices, frames;

name = getArgument;
namex = split(name,',');
f0 = namex[0];

MainStack = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);
StackTitle = MainStack;

selectWindow(MainStack);
run("Set Scale...", "distance=1 known=1 pixel=1 unit=um");

Img_Preprocess();

save(f0+'deBg.tif')

run("Quit");


// ----------Preprocesses image t-stack to subtract background
function Img_Preprocess () {
    // Clearing the Results window and Analyze menu � Set Measurements selections
    run("Set Measurements...", "redirect=None decimal=3");
    run("Clear Results");

    selectWindow(MainStack);
    run("Z Project...", "projection=[Average Intensity]");
    STDtitle = getTitle();
    StackTitle = Subtract_Background();
    selectWindow(STDtitle);
    run("Close");
    selectWindow("ROI Manager");
    run("Close");

    return;
}

// --------------Calculates the background pixel value for every frame as the average of pixel intensities
// in the user selected area
function Subtract_Background () {
    selectWindow(STDtitle);
    frame_width = getWidth();
    frame_height = getHeight();
    makeOval(0, 0, 50, 50);
    roiManager("Add");
    roiManager("select",0);

    // Get the xy coordinates of the ROI that has been set on the Z-projected image
    getSelectionBounds(sel_x, sel_y, sel_width, sel_height);
    roiManager("Delete");

    // Make another image stack
    selectWindow(MainStack);
    run("Duplicate...", "title=Background_Subtracted duplicate range=1-Stacklen");
    StackTitle = getTitle();
    Stacklen = nSlices;

    img_pix = newArray(frame_width*frame_height);
    new_pix = newArray(frame_width*frame_height);
    selectWindow(StackTitle);
    makeOval(sel_x, sel_y, sel_width, sel_height);
    roiManager("Add");
    roiManager("select",0);
    for (i=1; i<=Stacklen; i++) {
        // Get the avg intensity in that area
        setSlice(i);
        getSelectionCoordinates(subx, suby);
        pixval = newArray(subx.length);
        for (k=0; k<subx.length; k++) {
            // Get the pixel value
            pixval[k] = getPixel(subx[k],suby[k]);
        }

        // Find average of the pixel values
        Array.getStatistics(pixval, pix_min, pix_max, pix_mean, pix_stdDev);

        // Subtract that value from all the pixels of that frame
        for (n=0; n<frame_width; n++) {
            for (m=0; m<frame_height; m++) {
                // Subtract the above calculated average
                img_pix[m] = getPixel(n,m);
                new_pix[m] = img_pix[m]-pix_mean;
                setPixel(n,m, new_pix[m]);
            }
        }
    }

    return StackTitle;
}



