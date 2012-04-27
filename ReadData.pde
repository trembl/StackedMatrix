class ReadData {
  
	String lines[];
	
	int xLength = 0;    // dimensions
	int yLength = 0;
	int zLength = 0;
	
	color[][][] colors;  // color matrix
	float[][][] values;  // value matrix
	float minValue;
	float maxValue;
	
	float[] cubeSizes;
	float[] cellSizes = new float[3]; // = xSize/xCells;
	
	 // for depth sorting
	public Integer[] sortIndex;
	public float[] sortDistance;
	
	Point3f[] boxPositions;
        Point3f[] boxIndex;
   	color[] boxColors;

ReadData(String path, float[] s) {
    lines = loadStrings(path);
    cubeSizes = s;
    
    
    // getting dimensions
    for (int i=0; i<lines.length; i++) {
      if (match(lines[i], ">") != null) {			// ingore lines starting wi
        zLength++;                                    // count occurences of ">"
        if ( (zLength-1) > 0) {
          yLength = ((i-(zLength-1))/(zLength-1));    // get distance between ">"
        }
      }
    }

    String xCount[] = split(lines[1], TAB);          // check first line 
    xLength = xCount.length - 1;					// get length of x dimension
    //xLength = xCount.length;
    
    cellSizes[0] = cubeSizes[0]/xLength;
    cellSizes[1] = cubeSizes[1]/yLength;
    cellSizes[2] = cubeSizes[2]/zLength;
    
    println("cubeSizes[0]:" + cubeSizes[0] + ", cubeSizes[1]:" + cubeSizes[1] + ", cubeSizes[2]:" + cubeSizes[2]);
    println("cellSizes[0]:" + cellSizes[0] + ", cellSizes[1]:" + cellSizes[1] + ", cellSizes[2]:" + cellSizes[2]);

    
    println(lines.length + " lines, x:" + xLength + ", y:" + yLength + ", z:" + zLength);

	// init box positions
	int d = getDimensionProduct();
	boxPositions = new Point3f[d];
        boxIndex = new Point3f[d];
	println("boxPositions.length " + boxPositions.length);

	// init box colors
	boxColors = new color[d];

	// init sort arrays
	sortIndex = new Integer[d];
	resetSortIndex();
	sortDistance = new float[d];


	
}


void applyIndexSort() {
	
	// sort
	// NOT working with TextMate Bundle
	/*
		Arrays.sort(sortIndex, new Comparator<Integer>() {
	    	public int compare(final Integer o1, final Integer o2) {
	        	return Float.compare(sortDistance[o1], sortDistance[o2]) * -1;    // reverse sorting order  (-1,0,1) * -1 -> (1,0,-1)
	    	}
		});
	*/
	
}


void resetSortIndex() {
	for (int i=0; i<sortIndex.length; i++) {
		sortIndex[i] = i;
	}
}


int getDimensionProduct() {
	return xLength * yLength * zLength;
}


color[][][] makeColorMatrix() {
	values = new float[xLength][yLength][zLength];				// init values array
	float[] sortArray = new float[xLength*yLength*zLength];		// init sort array
   
	println(xLength + " " + yLength + " " + zLength);

	int x = 0;
	int y = 0;
	int z = -1;
   
	int sortIndex = 0;

	for (int i=0; i < lines.length; i++) {		// loop over lines in file
		//println(lines[0]);
		
		
		if ( match(lines[i], ">") == null ) {		// line does not start with ">"
			x = 0;									// reset x

			for(String s:split(lines[i], TAB) ) {          // split the line into values

				if (!Double.isNaN(float(s))) {                // if it's a number ...
					float v = float(s);						// cast as float
					// println(x + ", " + y + ", " + z + ": " + v);
					println("parsing: " + x + " " + y + " " + z + ": " + v);
					
					values[x][y][z] = v;          //matrix
					sortArray[sortIndex] = v;    // sort array
					sortIndex++;
					x++;
				} else {
					println("parse error: " + s);
				}
			}
			y++;
			
		} else {					// if line start with > .. 
			z++;            		// increase z
			y = 0;					// reset 0		
		}
		

	}

	// convert to XML
	

   // get highest/lowest values
   sortArray = sort(sortArray);
   minValue = sortArray[0];
   maxValue = sortArray[sortArray.length-1];
    
   // convert values to colors
   
   colors = new color[xLength][yLength][zLength];
   
	for(int cZ=0; cZ<zLength; cZ++) {
		for(int cY=0; cY<yLength; cY++) {
			for(int cX=0; cX<xLength; cX++) {
 			   //println("... " + cX + " " + cY + " " + cZ);  
			    float value = values[cX][cY][cZ];
			    //println("... " + value);
    
			    color c;
			    float qMin = 255/abs(minValue);
			    float qMax = 255/maxValue;
    
				float highMapped = map(value, minValue, maxValue, 0, 255);
				float lowMapped = map(value, minValue, maxValue, 255, 0);
				
			    if (value > 0) {
					// high, red
					
					
				    c = color(255, lowMapped, lowMapped);

				
				} else if (value < 0) {
					
					// low, green
					 c = color(lowMapped, 255, lowMapped);
					//blue
					//c = color(255-abs(value)*qMin, 255-abs(value)*qMin, 255);
				} else {	// white
					c = color(255, 255, 255);
				}
			    colors[cX][cY][cZ] = c;
			}
		}
	}
	println("minValue: " + minValue + ", maxValue: " + maxValue);
	
	float test = map(values[0][0][0], minValue, maxValue, 0, 255);
	println("\n\n" + test + "\n\n");
	
 	println("colors 0 0 0: " + hex(colors[0][0][0]) );
	println("colors 1 0 0: " + hex(colors[1][0][0]) );
	return colors;
	}
}

