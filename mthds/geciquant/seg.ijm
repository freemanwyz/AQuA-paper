//
// Modified by Yizhi for simulation
// Segment soma domains to sub ROIs
// Remove all user interaction parts and use appropriate settings from data
//
// Better to consider all stacks when thresholding (use "stack"),
// some frames do not contain much signal, which makes auto thresholding hard
//

// Global variables
var MainStack, StackTitle;
var width, height, channels, slices, frames;

name = getArgument;
namex = split(name,',');
f0 = namex[0];  // working directory
// f0 = "C:/Users/Eric/AppData/Local/Temp/geci/"

MainStack = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);
StackTitle = MainStack;

selectWindow(MainStack);
run("Set Scale...", "distance=1 known=1 pixel=1 unit=um");

list = getFileList(f0+"soma");
for (i=0; i<list.length; i++) {
    roiManager("reset");
    if (endsWith(list[i], ".roi")) {
        roiManager("open", f0+"soma"+File.separator+list[i]);
        ROI_Segmentation();
        // roiManager("select", 0);
        // roiManager("Delete");
        roiManager("save", f0+"soma"+File.separator+i+".zip");
        // waitForUser("Go");
    }
}

run("Quit");


// --------------Segmentation of ROI ----------------------------------------------------
function ROI_Segmentation () {
    min_area = "50";  // minimum sub-ROI area (pixels)
    persubroi_delete = "0.6";  // fraction of soma area for sub-ROI deletion
    spatiotemporal_SubROI();
    return;
}

// ------------------ Function to detect sub-ROI of soma based on spatio-temporal characteristics ---------------------------------
// This function provides a means to segment the somatic signal into spatially distinct subset of ROI that are extracted
// based on the temporal characteristics. Every 3 frames of the stack is averaged. In the reduced sub-stack, possible sub-
// ROI  within the main somatic ROI are detected for every frame. In the resulting ROI set, first all the sub-ROI that
// encompass > user-set percent area of the main somatic ROI are deleted. Next, spatially non-overlapping ROI, are
// extracted by comparing the x-y coordinates of each ROI with the other ROI and deteling all the ROI that spatially overlap.

function spatiotemporal_SubROI() {
    // ---------- Generate sub ROIs by averaging 3 frames ----------------
    selectWindow(StackTitle);
    run("Grouped Z Project...", "projection=[Standard Deviation] group=5");
    subStackTitle = getTitle();
    cnt = roiManager("count");
    if (cnt == 1) {
        selectWindow(subStackTitle);
        roiManager("select", 0);        // Select the somatic ROI (or S-ROI)
        getStatistics(soma_area, soma_mean);    // Get the area covered by S-ROI

        setAutoThreshold("Default dark");   // Threshold the substack
        //setAutoThreshold("Li dark stack");   // Threshold the substack
        
        run("Analyze Particles...", "size=min_area-soma_area circularity=0.00-1.00 show=Outlines display add stack");
        roi_count = roiManager("count");
        num = 0;
        roi_del = newArray(roi_count);

        // ------------------------ Set deletion flags for repeating ROI --------------------------
        num=0;
        for (i=1;  i<roi_count-1; i++) {  // For each sub ROI
            roiManager("select",i);
            getStatistics(roi_area,roi_mean);
            if (roi_area > (persubroi_delete)*(soma_area)) {
                roi_del[num]=i;
                num++;
            }
        }
        if (num > 0) {  // delete too large ROI
            delROI = newArray(num);
            for (k=0; k<num; k++)
                delROI[k] = roi_del[k];
            roiManager("select", delROI);
            roiManager("Delete");
        }

        roi_count = roiManager("count");
        num=0;
        for (i=1;  i<roi_count-1; i++) {  // For each ROI
            roiManager("select",i);
            getSelectionCoordinates(xval,yval);
            getStatistics(roi_area,roi_mean);
            for (j=i+1; j<roi_count; j++) {  // delete any ROI overlapped with i
                roiManager("select",j);
                distinct = 0;
                for (k=0; k<xval.length; k++) {
                    region = selectionContains(xval[k], yval[k]);
                    if (region == 1)
                        distinct++;
                }
                if (distinct > 0) {
                    roi_del[num]=j;
                    num++;
                }
            }
            if (num > 0) {
                delROI = newArray(num);
                for (k=0; k<num; k++)
                    delROI[k] = roi_del[k];
                roiManager("select", delROI);
                roiManager("Delete");
            }
            roi_count = roiManager("count");
            num=0;
        }

        roi_cnt = roiManager("count");
        for (i=1; i<roi_cnt; i++) {
            roiManager("select",i);
            roiManager("Rename","Seg_"+i);
        }

    } // (cnt == 1)
    return;
}


