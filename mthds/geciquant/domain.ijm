//
// Modified by Yizhi for simulation
// remove all user interaction parts and use appropriate settings from data
//
// DO NOT open file in macro; specify it in system call
//
// TODO
//

// Global variables
var MainStack, StackTitle;
var width, height, channels, slices, frames;
// var pixel_cal;

name = getArgument;
namex = split(name,',');
f0 = namex[0];
thrSz = namex[1];

MainStack = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);
StackTitle = MainStack;

selectWindow(MainStack);
pixel_cal = 1;
run("Set Scale...", "distance=1 known=pixel_cal pixel=1 unit=um");

ROI_Detection();

run("Quit");


// -------------------- Sets parameters for ROI detection
function ROI_Detection () {
    
    Min_area = thrSz; Max_area = "Infinity"; 
    prefix = "soma";
    Soma_Detection();
    
    n = roiManager("count");
    if (n>0){
        roiManager("save", f0+'soma.zip');  // save ROIs
    }
    roiManager("reset");
    
    Min_area = "4"; Max_area = thrSz; 
    prefix = "md";
    Microdomain_Detection();
    n = roiManager("count");
    if (n>0){
        roiManager("save", f0+'domain.zip');  // save ROIs
    }    
    roiManager("reset");

    return;
}

// ---------Soma Detection -----------
function Soma_Detection() {
    selectWindow(StackTitle);
    run("Z Project...", "projection=[Max Intensity]");
    run("Smooth");
    STDtitle = getTitle();
    //setAutoThreshold("Li dark");
    setAutoThreshold("Default dark");

    run("Threshold...");
    getThreshold(auto_lower,auto_upper);
    // setThreshold(thr, auto_upper);
    run("ROI Manager...");

    // draw polygon
    // makeRectangle(20, 20, 100, 100)
    makeRectangle(0, 0, width, height);
    roiManager("Add");
    roiManager("select",0);

    // find particles
    cellcnt = roiManager("count");
    polycnt = newArray(cellcnt);
    for (i=0; i<cellcnt; i++)
        polycnt[i] = i;
    getThreshold(user_lower,user_upper);

    print(Min_area);
    print(Max_area);
    for (roi_pos=0; roi_pos<cellcnt; roi_pos++) {
        selectWindow(STDtitle);
        roiManager("select", roi_pos);
        run("Analyze Particles...", "size=Min_area-Max_area circularity=0.00-1.00 show=Outlines add stack");
    }
    roiManager("Select",polycnt);
    roiManager("Delete");
    print('Counting...');
    cellcnt = roiManager("count");
    for (roi_pos=0; roi_pos<cellcnt; roi_pos++) {
        roiManager("select", roi_pos);
        roiManager("Rename",prefix+"_"+(roi_pos+1));
    }

    return;
}

// ----------- Microdomain detection --------------------------------------------------
function Microdomain_Detection() {
    selectWindow(StackTitle);
    run("Z Project...", "projection=[Max Intensity]");
    run("Smooth");
    STDtitle = getTitle();
    //setAutoThreshold("Li dark");
    setAutoThreshold("Default dark");
    run("Threshold...");
    getThreshold(auto_lower,auto_upper);
    // setThreshold(thr, auto_upper);
    run("ROI Manager...");
    
    makeRectangle(0, 0, width, height);
    roiManager("Add");
    roiManager("select",0);

    cellcnt = roiManager("count");

    if (cellcnt > 0) {
        polycnt = newArray(cellcnt);
        for (i=0; i<cellcnt; i++) {
            polycnt[i] = i;
        }
        getThreshold(user_lower,user_upper);
        roiManager("select", polycnt);
        selectWindow(STDtitle);
        run("Analyze Particles...","size=Min_area-Max_area circularity=0.00-1.00 show=Outlines add stack");

        for (roi_pos=0; roi_pos<cellcnt; roi_pos++) {
            roiManager("select", roi_pos);
            roiManager("Rename","Territory_"+(roi_pos+1));
        }

        roicnt = roiManager("count");
        for (roi_pos=cellcnt; roi_pos<roicnt; roi_pos++) {
            roiManager("select", roi_pos);
            roiManager("Rename",prefix+"_"+(roi_pos));
        }

    }
    else
        exit("Please draw a polygon around the astrocyte territory and restart");

    return;
}
