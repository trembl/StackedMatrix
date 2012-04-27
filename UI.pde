
class UI {

  PMatrix3D currCameraMatrix;
  PGraphics3D g3; 

  Slider xS,yS,zS;
  Slider transparency;
  Toggle gridToggle;
  RadioButton viewSwitch;

	Range minusRange, plusRange;
	Textlabel fpsLabel;

  UI(ReadData data) {
   
	
    g3 = (PGraphics3D)g;

	
  


	makeRangeSlider(100, data.xLength, 10, 10);			// id=100, X Slider			//i nt id, int maxValue, int x, int y
	makeRangeSlider(200, data.yLength, 10, 30);			// id=200, Y Slider
	makeRangeSlider(300, data.zLength, 10, 50);			// id=300, Z Slider
	
    transparency = (Slider)controlP5.addSlider("Transparency",0,1,1,10,height-30,200,20);
	colorSetup(transparency);
    //transparency.setLabel("Z");
    transparency.setLabelVisible(true);

	minusRange = controlP5.addRange("minus", -1,0,-1,0, 10,200,135,14);
	minusRange.setId(500);
	minusRange.setLabel("");
	colorSetup(minusRange);
	
	plusRange = controlP5.addRange("plus", 0,1,0,1, 145,200,135,14);
	plusRange.setId(501);
	plusRange.setLabel("");
	colorSetup(plusRange);
	
    
    gridToggle = (Toggle)controlP5.addToggle("tog",true,width-30,10,20,20);
    colorSetup(gridToggle);
    gridToggle.setLabel("Box");
    
	

	viewSwitch = (RadioButton)controlP5.addRadioButton("viewSwitch",400,10);
	viewSwitch.setColorActive(color(127));							
    viewSwitch.setColorBackground( color(200,100) );
    viewSwitch.setColorForeground(color(150,100));
    viewSwitch.setColorLabel(color(127));
    viewSwitch.setColorValue(color(127));
	viewSwitch.setItemsPerRow(4);
	viewSwitch.setSpacingColumn(20);
	viewSwitch.addItem("X", 1);
	viewSwitch.addItem("Y", 2);
	viewSwitch.addItem("Z", 4);
	viewSwitch.addItem("XYZ", 7);
	
//	controlP5.addBang("depthBang",width-60,10,20,20);
	
	
	
    controlP5.setAutoDraw(false);
  }
/*
void additionalSliderSetup(Range theRange) {		// simplify/unify Slider creating
	colorSetup(theRange);
    theRange.setLabelVisible(true);
    theRange.showTickMarks(true);
    theRange.snapToTickMarks(true);
}
*/
void colorSetup(Controller c) {						// unfied colors
	
	c.setColorActive(color(127));							
    c.setColorBackground( color(200,100) );
    c.setColorForeground(color(150,100));
    c.setColorLabel(color(127));
    c.setColorValue(color(127));

}


void makeRangeSlider(int id, int maxValue, int x, int y) {
  
  ControlGroup rangeGroup = controlP5.addGroup("g"+id,x,y,270);
  rangeGroup.activateEvent(true);
  rangeGroup.hideBar();
  rangeGroup.disableCollapse();
  
  Range range = controlP5.addRange("r"+id, 1,maxValue,1,maxValue, 36,0,200,14);
  range.setLabel("");
  range.setGroup(rangeGroup);
  range.setDecimalPrecision(0);
  range.setSliderMode(1);
  range.setId(id);
	colorSetup(range);

  Button range_low_minus = controlP5.addButton("b"+id+10, 0,0,0,14,14);
  range_low_minus.setLabel("-");
  range_low_minus.setGroup(rangeGroup);
  range_low_minus.setId(id+10);
	colorSetup(range_low_minus);
  
  Button range_low_plus = controlP5.addButton("b"+id+20, 0,18,0,14,14);
  range_low_plus.setLabel("+");
  range_low_plus.setGroup(rangeGroup);
  range_low_plus.setId(id+20);
	colorSetup(range_low_plus);
  
  Button range_high_minus = controlP5.addButton("b"+id+30, 0,240,0,14,14);
  range_high_minus.setLabel("-");
  range_high_minus.setGroup(rangeGroup);
  range_high_minus.setId(id+30); 
	colorSetup(range_high_minus);
  
  Button range_high_plus = controlP5.addButton("b"+id+40, 0,256,0,14,14);
  range_high_plus.setLabel("+");
  range_high_plus.setGroup(rangeGroup);
  range_high_plus.setId(id+40); 
	colorSetup(range_high_plus);
}






void gui() {
    currCameraMatrix = new PMatrix3D(g3.camera);
    camera();

	
	if(gridToggle.getState() == false ) {
		hint(ENABLE_DEPTH_SORT);
		println("depthSort");
	} else {
		hint(DISABLE_DEPTH_SORT);
	}
	

    controlP5.draw();

	
	/*
	// toggle frameRate display
	fill(0);
	text((int)frameRate,20,500);
	*/
    g3.camera = currCameraMatrix;
    

}




// control event, called from main class

void controlEvent(ControlEvent e) {
  
	if (e.id() >= 100 && e.id() < 200) {
		slidersControl( (Range)controlP5.controller("r100"), e.id() );  
	} else if (e.id() >= 200 && e.id() < 300) {
		slidersControl( (Range)controlP5.controller("r200"), e.id() );  
	} else if (e.id() >= 300 && e.id() < 400) {
		slidersControl( (Range)controlP5.controller("r300"), e.id() );  
  	} 
  
}

void slidersControl(Range r, int e_id) {
    

    switch (e_id - r.id() ) {
      case 0:
		println("RangeSlider " + r.id()  + " low: " + round(r.lowValue()) + ", high: " + round(r.highValue()) ); 
        break;
      case 10:
        if (r.lowValue() > 0) r.setLowValue(r.lowValue()-1); break;
      case 20:
        if (r.lowValue() < r.highValue()) r.setLowValue((int)r.lowValue()+1); break;
      case 30:
        if (r.highValue() > r.lowValue()) r.setHighValue(r.highValue()-1); break;
      case 40:
        if (r.highValue() < r.max()) r.setHighValue((int)r.highValue()+1); break;
    }
    
}


int getRange(String dimension, String lowOrHigh) {
	// query for range values
	
	String[] dimNames = {"x", "y", "z"};
	String[] rangeNames = {"r100", "r200", "r300"};		// map dim names to UI names
	int index = Arrays.binarySearch(dimNames, dimension);
	
	Range r = (Range)controlP5.controller(rangeNames[index]);

	float rValue = (lowOrHigh.equals("low")) ? r.lowValue() : r.highValue();
	
	return (int)rValue;
}


int getMinusLow() {
	return 255-(int)(255*abs(minusRange.lowValue()));
}

int getMinusHigh() {
	return 255-(int)(255*abs(minusRange.highValue()));
}

int getPlusLow() {
	return 255-(int)(255*plusRange.highValue());
}

int getPlusHigh() {
	
	return 255-(int)(255*plusRange.lowValue());
}


	
}

