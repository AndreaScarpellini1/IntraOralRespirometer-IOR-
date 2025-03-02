void drawBackground() {
  background(21, 31, 59); // Set the background to a very dark blue (midnight blue)
  
  // Draw the title
  fill(255); // Set the color to white for the text
  textSize(60); // Maintain text size for visibility and impact
  PFont font = createFont("Helvetica", 60, true); // Continue using the Georgia font, bold
  textFont(font); // Apply the font
  float titleWidth = textWidth("Smart Retainer"); // Calculate the width of the title text
  // Calculate the position to start the title to make it centered
  float titleX = (width - titleWidth) / 2;
  float titleY = height / 8; // Keep the title higher on the screen
  text("Smart Retainer", titleX, titleY); // Position the text centered on the screen
  pushMatrix();
  stroke(255);
  line(20, titleY-15, titleX-20, titleY-15);
  line( titleX+20+titleWidth, titleY-15, 1580 , titleY-15);
  popMatrix();
  
  // Draw the subtitle
    textSize(30); // Smaller text size for the subtitle
    PFont subtitleFont = createFont("Helvetica", 30, true); // Optionally use a different or the same font
    textFont(subtitleFont); // Apply the subtitle font
    float subtitleWidth = textWidth("IntraOral Respirometer"); // Calculate the width of the subtitle
    float subtitleX = (width - subtitleWidth) / 2; // Center the subtitle
    float subtitleY = titleY + 60; // Position the subtitle below the title
    text("IntraOral Respirometer", subtitleX, subtitleY); // Display the subtitle centered
  
  // Draw a large white box in the middle
  fill(255); // Set the fill color to white for the box
  noStroke(); // No border for the box
  rectMode(CENTER); // Set the rect mode to center
  rect(width / 2, height / 2 - 40, 800, 400); // Further increase the size of the rectangle

  // Draw four small squares below the large box
  int squareSize = 150; // Further increase the size of each small square
  int spacing = 60; // Increase the space between squares to accommodate larger sizes
  int startY  = (height / 2 + 300)-40; // Adjust the Y position to start drawing squares, considering the new box size

  // Calculate the starting X position to center the squares
  float startX = width / 2 - (1.5 * squareSize + 1.5 * spacing);

  for (int i = 0; i < 4; i++) {
    rect(startX + i * (squareSize + spacing), startY, squareSize, squareSize);
  }
   fill(0); // Black text color
   textSize(70);
   int truncatedHR = (int) HR;
   int truncatedoxy = (int) oxy;
   int truncatedpitch = (int) -(pitch-pitch_cal);
   int truncatedroll = (int) -(roll-roll_cal);
   text(truncatedHR, startX + 0 * (squareSize + spacing)-textWidth(str(truncatedHR))/2, startY+20);
   text(truncatedoxy, startX + 1 * (squareSize + spacing)-textWidth(str(truncatedHR))/2, startY+20);
   text(truncatedpitch, startX + 2 * (squareSize + spacing)-textWidth(str(truncatedHR))/2, startY+20);
   text(truncatedroll, startX + 3 * (squareSize + spacing)-textWidth(str(truncatedHR))/2, startY+20);
   
   fill(0);
   textSize(20);
   text("  HEART RATE  ", startX + 0 * (squareSize + spacing)-textWidth("- HEART RATE -")/2, startY+70);
   text("  OXYGENATION  " , startX + 1 * (squareSize + spacing)-textWidth("- OXYGENATION -" )/2, startY+70);
   text("  HEAD PITCH  ", startX + 2 * (squareSize + spacing)-textWidth("- HEAD PITCH -")/2, startY+70);
   text("  HEAD ROLL  " , startX + 3 * (squareSize + spacing)-textWidth("- HEAD ROLL -" )/2, startY+70);
  if (!headposacquired){
     fill(255,0,0);
     rect(1011,870,320,40);
     fill(0);
     text("Calibrate the head position",900,870);
  }
  else{
    fill(0,255,0);
    rect(1011,870,320,40);
    fill(0);
    text("Head Position Calibraated",900,870);
  }

  //rect for counting breathing 
  fill(255);
  rect(1350,310,250,100);
  PFont fontbpm = createFont("Helvetica", 40, true); // Continue using the Georgia font, bold
  textFont(font); // Apply the font
  pushMatrix();
  fill(0);
  textFont(fontbpm); // Apply the font
  //text("Bpm", 1360, 320);
  //text(breathingRateBPM,1320,320);
  text(int(breathingRateBPM), 1320, 320);

  popMatrix();
  
  
  // footer 
  pushMatrix();
  stroke(color(200,200,200));
  line(20, height-45, 1600-20, height-45);
  popMatrix();
  
  pushMatrix();
  fill(color(240, 75, 76));
 
  PFont footerFont = createFont("Helvetica", 20, true); // Optionally use a different or the same font
  textFont(footerFont); // Apply the subtitle font
  float footerWidth = textWidth("WTSE Lab - UIC"); // Calculate the width of the subtitle
  float footerX = (width - footerWidth) / 2; // Center the subtitle
  float footerY = height-10; // Position the subtitle below the title
  text("WTSE Lab - UIC", footerX, footerY); // Display the subtitle centered
  popMatrix();
  
  //BUTTONS 
  
  fill(255); // White fill for the button
  stroke(0, 0, 0); // Red border for the button
  rect(150, 310, 200, 100);

  // Calculate the center of the rectangle
  float centerX = 150;
  float centerY = 310;

  // Draw the button text
  fill(0); // Black text color
  textSize(20);
  String buttonText=" ";
  String countDownbutton = "";

  // Determine the text to be displayed
  if( baseline_acquired){
     buttonText= "Baseline Acquired!" ;
     countDownbutton = str(baselinecountdown)+"...";
  }
  if(start_baseline){
     buttonText="Acquiring";
     countDownbutton = str(baselinecountdown)+"...";
     noFill();
     strokeWeight(5);
     stroke(155, 0, 0); // Red border for the button
     rect(150, 310, 200, 100);
  }
  if(!baseline_acquired & !start_baseline){
     buttonText="Acquire Baseline";
     countDownbutton = " ";
  }
  if(baseline_acquired & !start_baseline){
     buttonText="Re-Acquire Baseline";
     countDownbutton = " ";
 }
  float textWidth = textWidth(buttonText);
  float textX = centerX-textWidth/2;
  float textY = centerY;
  text(buttonText, textX, textY); // Draw the text
  text(countDownbutton, textX, textY+15);

  //charts
  //draw_breathingChart();
  //draw_breathingChartSIGN();
  draw_CB_breathingChart();
}

//void draw_breathingChart(){
//  pushMatrix();
//  // Set font style for chart text
//  PFont chartFont = createFont("Georgia", 28); // Smaller size than title and use the same font
//  textFont(chartFont);
//  fill(128, 128, 128); // Gray color for chart text
//  popMatrix();
//  // Translate drawing context to start chart inside the white box
//  pushMatrix(); // Save the current transformation matrix
//  translate(width / 2 - 375, height / 2 - 215); // Move origin to the top-left corner of the box
  
//   // Draw the breathing chart at the new origin, fitting inside the box
//   breathingLineChart.draw(0, 0, 750, 350); // Draw the chart with specified width and heigh
//   // Draw four horizontal lines within the white box
//   stroke(200); // Set line color to light gray for visibility
//   strokeWeight(1); // Set line thickness
    
//   line(18, 102-78, 750, 102-78); // Draw line across the width of the chart
//   line(18, 102+78, 750, 102+78); // Draw line across the width of the chart
//   line(18, 102+2*78, 750, 102+2*78); // Draw line across the width of the chart
//   line(18, 102, 750, 102); // Draw line across the width of the chart


//    popMatrix(); // Restore the previous transformation matrix
//}


//void draw_breathingChartSIGN(){
//  pushMatrix();
//  // Set font style for chart text
//  PFont chartFont = createFont("Georgia", 28); // Smaller size than title and use the same font
//  textFont(chartFont);
//  fill(128, 128, 128); // Gray color for chart text
//  popMatrix();
//  // Translate drawing context to start chart inside the white box
//  pushMatrix(); // Save the current transformation matrix
//  translate(width / 2 - 375, height / 2 - 215); // Move origin to the top-left corner of the box
  
//   // Draw the breathing chart at the new origin, fitting inside the box
//   breathingLineSIGNChart.draw(0, 0, 750, 350); // Draw the chart with specified width and heigh
//   // Draw four horizontal lines within the white box
//   stroke(200); // Set line color to light gray for visibility
//   strokeWeight(1); // Set line thickness 
//   popMatrix(); // Restore the previous transformation matrix
//}

void draw_CB_breathingChart(){
  pushMatrix();
  // Set font style for chart text
  PFont chartFont = createFont("Georgia", 28); // Smaller size than title and use the same font
  textFont(chartFont);
  fill(128, 128, 128); // Gray color for chart text
  popMatrix();
  // Translate drawing context to start chart inside the white box
  pushMatrix();                                 // Save the current transformation matrix
  translate(width / 2 - 375, height / 2 - 215); // Move origin to the top-left corner of the box
  
   // Draw the breafthing chart at the new origin, fitting inside the box
   CB_breathingLineChart.draw(0, 0, 750, 350); // Draw the chart with specified width and heigh
   // Draw four horizontal lines within the white box
   stroke(200);                               // Set line color to light gray for visibility
   strokeWeight(1);                           // Set line thickness
    
   line(18, 102-78, 750, 102-78);     // Draw line across the width of the chart
   line(18, 102+78, 750, 102+78);     // Draw line across the width of the chart
   line(18, 102+2*78, 750, 102+2*78); // Draw line across the width of the chart
   line(18, 102, 750, 102);           // Draw line across the width of the chart


    popMatrix(); // Restore the previous transformation matrix
}
