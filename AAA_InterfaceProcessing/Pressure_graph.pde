XYChart breathingLineChart;
XYChart CB_breathingLineChart;
XYChart breathingLineSIGNChart;

FloatList breathingLineChartX;
FloatList breathingLineChartY;
FloatList breathingLineSIGNChartX;
FloatList breathingLineSIGNChartY;
FloatList CB_breathingLineChartX;
FloatList CB_breathingLineChartY;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void graph_setup_breathing() {
  breathingLineChart = new XYChart(this);
  breathingLineChartX = new FloatList();
  breathingLineChartY = new FloatList();

  breathingLineChart.setData(breathingLineChartX.array(), breathingLineChartY.array());
  
  // Set the range for data display
  breathingLineChart.setMinY(-30);
  breathingLineChart.setMaxY(30); // Max value on y-axis based on expected range

  // Styling the chart
  breathingLineChart.showXAxis(true);
  breathingLineChart.showYAxis(true);
  breathingLineChart.setPointColour(color(240, 75, 76)); // Red points for visibility
  breathingLineChart.setLineColour(color(240, 75, 76)); // Red line for consistency
  
  // Connect the dots with a line
  // breathingLineChart.setLineVisible(true); // Ensure the line is displayed connecting the points

  // Increase the width of the dots and the line
  breathingLineChart.setPointSize(10); // Increase point size for better visibility
  breathingLineChart.setLineWidth(3); // Increase line width for better visibility
}


void graph_serialEvent_lungs(float pressure,long timestamp) {
  float sotime = (float) timestamp/1000;
  breathingLineChartX.append(sotime);
  breathingLineChartY.append(pressure); 

  if (breathingLineChartX.size() > 100 && breathingLineChartY.size() > 100) {
    breathingLineChartX.remove(0);
    breathingLineChartY.remove(0);
  }
  breathingLineChart.setData(breathingLineChartX.array(), breathingLineChartY.array());
}

void CB_graph_setup_breathing() {
  CB_breathingLineChart = new XYChart(this);
  CB_breathingLineChartX = new FloatList();
  CB_breathingLineChartY = new FloatList();

  CB_breathingLineChart.setData(CB_breathingLineChartX.array(), CB_breathingLineChartY.array());
  
  // Set the range for data display
  CB_breathingLineChart.setMinY(-30);
  CB_breathingLineChart.setMaxY(+30); // Max value on y-axis based on expected range

  // Styling the chart
  CB_breathingLineChart.showXAxis(true);
  CB_breathingLineChart.showYAxis(true);
  CB_breathingLineChart.setPointColour(color(240, 0, 76)); 
  CB_breathingLineChart.setLineColour(color(240, 0, 76));
  
  // Connect the dots with a line
 // breathingLineChart.setLineVisible(true); // Ensure the line is displayed connecting the points

  // Increase the width of the dots and the line
  CB_breathingLineChart.setPointSize(10); // Increase point size for better visibility
  CB_breathingLineChart.setLineWidth(3); // Increase line width for better visibility
}


void CB_graph_serialEvent_lungs(float pressure,long timestamp) {
  float sotime = (float) timestamp/1000;
  CB_breathingLineChartX.append(sotime);
  CB_breathingLineChartY.append(pressure); 

  if (CB_breathingLineChartX.size() > 100 && CB_breathingLineChartY.size() > 100) {
    CB_breathingLineChartX.remove(0);
    CB_breathingLineChartY.remove(0);
  }
  CB_breathingLineChart.setData(CB_breathingLineChartX.array(), CB_breathingLineChartY.array());
}
