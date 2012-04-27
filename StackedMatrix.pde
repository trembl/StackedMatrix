import processing.opengl.*;
import javax.media.opengl.GL;  
import peasy.*;
import controlP5.*;
import javax.vecmath.Point3f;
import oscP5.*;
import netP5.*;

ControlP5 controlP5;
PeasyCam cam;

ReadData data;
color[][][] colors;

float[] previousPosition;
float tempTrans;
// camera overlay
/*
PMatrix3D currCameraMatrix;
 PGraphics3D g3; 
 */

UI ui;
color boxFill;

CameraState stateX, stateY, stateZ, stateXYZ;
Point3f cameraPosition;
OscP5 oscP5;

void setup() {

	size(900, 700, OPENGL);
        //size(1024, 768, OPENGL);
	//hint(ENABLE_DEPTH_SORT);
	hint(DISABLE_DEPTH_TEST);
	hint(DISABLE_OPENGL_ERROR_REPORT);
	frameRate(30);
	
	oscP5 = new OscP5(this, 50000);	// create oscP5 instance, listen for incoming messages at port 
	
//	String fileName = "toyData.tns";
//	String fileName = "input.tns";
//	String fileName = "epiGen.clusterd.tns";
	String fileName = "paul.tns";
	
	float cubeSize = 440;

	float[] cubeSizes = {cubeSize, cubeSize, cubeSize};    // dimensions of the cube
	data = new ReadData(fileName, cubeSizes);
	//data = new ReadData("epiGen.clusterd.tns", cubeSizes);
	colors = data.makeColorMatrix();
	
	// ui
	controlP5 = new ControlP5(this);
	ui = new UI(data);
	
	
	  
	//lights();
	//directionalLight(255, 255, 255, 1, 0, 0);
	noStroke();
	//stroke(255);
	
	float fov = 4*PI/3.0; 
	float cameraZ = (height/2.0) / tan(PI * fov / 360.0); 
	perspective(fov, float(width)/float(height), cameraZ/2.0, cameraZ*2.0); 
	
	
	// orthographic view
	ortho(-width/2, width/2, -height/2, height/2, -1000, 2000); 
	
	


  	// PeasyCam Setup
  	cam = new PeasyCam(this, 750);
  	cam.setMinimumDistance(-500);
  	cam.setMaximumDistance(1500);
	cam.setResetOnDoubleClick(false);
	
	cam.setRotations(0, 0, 0);
	stateX = cam.getState();
	
	cam.setRotations(0, HALF_PI, 0);
	stateY = cam.getState();
	
	cam.setRotations(HALF_PI, 0, 0);
	stateZ = cam.getState();
	
	cam.setRotations(PI/4, atan(sin(PI/4)), -PI*5/6);
	stateXYZ = cam.getState();
	
	cam.setState(stateX, 0);
	ui.viewSwitch.activate(0);
	
	
	println("data.xLength " + data.xLength);
	println("data.yLength " + data.yLength);
	println("data.zLength " + data.zLength);
	
	for (int x=0; x<data.xLength; x++) {
		for (int y=0; y<data.yLength; y++) {
			for (int z=0; z<data.zLength; z++) {		
				int i = x*data.yLength*data.zLength + y*data.zLength + z;	
				Point3f p = new Point3f((-data.cubeSizes[0]/2)+x*data.cellSizes[0], (-data.cubeSizes[1]/2)+y*data.cellSizes[1], (-data.cubeSizes[2]/2)+z*data.cellSizes[2]);
				data.boxPositions[i] = p;
                data.boxIndex[i] = new Point3f(x, y, z);
				data.boxColors[i] = colors[x][y][z];
			}
		}
	}
	

}

// incoming osc message
void oscEvent(OscMessage theOscMessage) {
  /* get and print the address pattern and the typetag of the received OscMessage */
  println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  theOscMessage.print();
}

// mousepointer
void mousePressed() {
	cursor(HAND);
}
void mouseReleased() {
	cursor(ARROW);
}


void draw() {
//	background(240);   // clear background
        background(0);
	fill(0);

// toggle wireframe cube
	if( ui.gridToggle.getState() ) {
		noFill();
		stroke(200);
		box(data.cubeSizes[0], data.cubeSizes[1], data.cubeSizes[2]);
		noStroke();
	}



 	// compensate for drawing in the center
	translate(data.cellSizes[0]/2, data.cellSizes[1]/2, data.cellSizes[2]/2);
	int x,y,z;
	int xLow = int(ui.getRange("x","low")-1);
	int xHigh = int(ui.getRange("x","high"));
	int yLow = int(ui.getRange("y","low")-1); 
	int yHigh = int(ui.getRange("y","high")); 
	int zLow = int(ui.getRange("z","low")-1);
	int zHigh = int(ui.getRange("z","high"));

	int sequential;

	//	println("boxPositon " + data.boxPositions[1000].x );
	
	// get cameraPosition once every draw
	cameraPosition = new Point3f(cam.getPosition());
		//	println("cameraPosition " + cameraPosition.x + " " + cameraPosition.y + " " + cameraPosition.z);
		//	println("boxPosition " + boxPosition.x + " " + boxPosition.y + " " + boxPosition.z);
		//	println("distance " + pointTest.distance(cameraPosition));


// check distance
	data.resetSortIndex();

	for (x=0; x<data.xLength; x++) {
		for (y=0; y<data.yLength; y++) {
			for (z=0; z<data.zLength; z++) {
				sequential = x*data.yLength*data.zLength + y*data.zLength + z;
				Point3f p = data.boxPositions[sequential];
				data.sortDistance[sequential] = p.distance(cameraPosition);
			}
		}
	}
	
	// sort
	data.applyIndexSort();

	int boxNr;
	int seq = 0;

// render
	float lowRange, highRange;
	
	for (x=0; x<data.xLength; x++) {
		for (y=0; y<data.yLength; y++) {
			for (z=0; z<data.zLength; z++) {

                pushMatrix(); // push/pop once, to reset to origin
				sequential = x*data.yLength*data.zLength + y*data.zLength + z;

				boxNr = data.sortIndex[seq];


				Point3f p = data.boxPositions[boxNr];
				translate(p.x, p.y, p.z);
				
				
		
		
				boxFill = data.boxColors[boxNr];
				//boxFill = colors[x][y][z];
				boxFill = color(red(boxFill), green(boxFill), blue(boxFill), saturation(boxFill) + 255*tempTrans );
				
			
				

				Point3f s = data.boxIndex[boxNr];
				boolean slice = ( (s.x>=xLow && s.x<xHigh) && (s.y>=yLow && s.y<yHigh) && (s.z>=zLow && s.z<zHigh) );
                
				boolean skin = (s.x==xLow || s.x==xHigh-1 || s.y==yLow || s.y==yHigh-1 || s.z==zLow || s.z==zHigh-1 || (ui.transparency.value() != 1.0f) || (ui.getMinusHigh()!=255) || (ui.getPlusHigh()!=255) );

				boolean range = ((green(boxFill) >= ui.getMinusLow()) && (green(boxFill) <= ui.getMinusHigh())) || ((red(boxFill) >= ui.getPlusLow()) && (red(boxFill) <= ui.getPlusHigh()));

         
				if (range) {  // filter boxes outside range
					if (slice) {
						if (skin) {
							fill(boxFill);
							box(data.cellSizes[0], data.cellSizes[1], data.cellSizes[2]);
						}
					}
          		}
				seq++;
        		popMatrix();
        
        

			}		// closing for loops
		}
	}


	
	


	// opaque when moving
	tempTrans = ui.transparency.value();
	/*
	if(Arrays.equals(previousPosition, cam.getPosition()) == false) {
		tempTrans = 1.0;
	}
	*/
	
	previousPosition = cam.getPosition();


	// ui over content
	cam.beginHUD();
	ui.gui();
	cam.endHUD();

	// do not move content, when over ui
	//cam.setMouseControlled(true);
	cam.setMouseControlled(!controlP5.window(this).isMouseOver());		// checks if mouse is over controlP5 element
}


void controlEvent(ControlEvent e) {
	// notifications from controlP5
	//print("got an event from "+theEvent.group().name()+"\t");
	//print("got an event from \n");
	ui.controlEvent(e);
	
	
	String name = "";
	if (e.isController()) {
		name = e.name();
	} else if (e.isGroup()) {
		name = e.group().name();
	}
	
	if ( name.equals("viewSwitch") ) {
		//camera.lookAt(double x, double y, double z);
		float[] look = cam.getRotations();
		print("got an event from viewSwitch: " + look[0] + " " + look[1] + " " + look[2] + "\n");

		print("value " + e.group().value() + "\n");
		
		
		switch ((int)e.group().value()){
			case 1:
				cam.setState(stateX, 1000); break;
			case 2:
				cam.setState(stateY, 1000); break;
			case 4:
				cam.setState(stateZ, 1000); 
				break;
			case 7:
				cam.setState(stateXYZ, 1000); break;
		}
					
	} else if ( name.equals("TestSlider") ) {

	}

	
}







