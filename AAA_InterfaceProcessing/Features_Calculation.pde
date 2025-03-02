import java.util.ArrayList;
import java.util.Collections;

ArrayList<Float> PressureLst = new ArrayList<Float>();
ArrayList<Integer> PressureSgnLst = new ArrayList<Integer>();
int patternCount=0;
final int MAX_SIZE = 400;


////++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//// BREATHING RATE CALCULAION 
////++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//void addPressureLst(float newValue, long timestamp) {

//  // Append the new value to the pressure list
//  PressureLst.add(newValue);

//  // Calculate the standard deviation if the list has enough elements
//  float std = 0;
//  float TH = 0;
//  if (PressureLst.size() > 1) {
//    std = calculateStandardDeviation(PressureLst);
//  }

//  // Determine the sign value based on the new value's relation to the standard deviation.
//  //when the subject is not breathing the std is between 0.5 and 0.7

//  if (std<1) {
//    TH = 2;
//  } else {
//    TH = std;
//  }

//  int signValue;
//  if (newValue < -TH) {
//    signValue = -1;
//  } else if (newValue > TH) {
//    signValue = 1;
//  } else {
//    signValue = 0;
//  }

//  //print("std: ");
//  //print(std);
//  // Append the sign value to the sign list
//  PressureSgnLst.add(signValue);
//  // Draw the value in the graph
//  graph_serialEvent_lungsSIGN(signValue, timestamp);
//  // Count the pattern
//  if (PressureSgnLst.size()>100) {
//    countPattern(PressureSgnLst);
//  }
//  //print("SIGN VALUE: ");
//  //print(signValue);
//  //print(",");
//  //println(patternCount/2);
//  // Check if the pressure list size exceeds the maximum size
//  if (PressureLst.size() > MAX_SIZE) {
//    // Remove the first element to maintain the list size at MAX_SIZE
//    PressureLst.remove(0);
//  }

//  // Check if the sign list size exceeds the maximum size
//  if (PressureSgnLst.size() > MAX_SIZE) {
//    // Remove the first element to maintain the list size at MAX_SIZE
//    PressureSgnLst.remove(0);
//  }
//}

//// Function to calculate the standard deviation of an ArrayList
//float calculateStandardDeviation(ArrayList<Float> list) {

//  // Calculate the mean
//  float sum = 0;
//  for (float num : list) {
//    sum += num;
//  }
//  float mean = sum / list.size();

//  // Calculate the variance
//  float varianceSum = 0;
//  for (float num : list) {
//    varianceSum += (num - mean) * (num - mean);
//  }
//  float variance = varianceSum / list.size();

//  // Return the standard deviation
//  return (float) Math.sqrt(variance);
//}


//void countPattern(ArrayList<Integer> inputList) {
//  // Reset the count
//  patternCount = 0;

//  // Iterate through the list looking for patterns
//  int index = 0;
//  while (index < inputList.size()) {
//    // Look for the starting `0`
//    if (inputList.get(index) == 0) {
//      int j = index + 1;
//      boolean validPattern = false;

//      // Check for a series of consecutive `-1`s or `+1`s
//      if (j < inputList.size() && (inputList.get(j) == -1 || inputList.get(j) == 1)) {
//        int firstValue = inputList.get(j);

//        // Continue until the series breaks
//        while (j < inputList.size() && inputList.get(j) == firstValue) {
//          j++;
//        }

//        // If a `0` follows the series, a valid pattern is found
//        if (j < inputList.size() && inputList.get(j) == 0) {
//          validPattern = true;
//          index = j; // Move past this pattern
//        } else {
//          index++; // Increment to continue searching for the next pattern
//        }

//        // Increment the pattern count if a valid pattern is found
//        if (validPattern) {
//          patternCount++;
//        }
//      } else {
//        index++; // Skip to the next element if not part of a pattern
//      }
//    } else {
//      index++;
//    }
//  }
//}

////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//// ROOT MEAN SQUARE ACCELERATION CALCULATION 
////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
