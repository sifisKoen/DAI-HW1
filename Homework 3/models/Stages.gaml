/**
* Name: Stages
* Based on the internal empty template. 
* Author: iosif
* Tags: 
*/


model Stages

/* Insert your model definition here */

global {
	
	list<point> StagesPosition <- [{15, 15}, {85, 15}, {15, 85},{85, 85}];
	
	list<rgb> StageColors <- [#olive, #silver, #purple, #blue];

	
	int NumberOfGuests <- 30;
	int NumberOfStages <- 4;
	
	int distanceThreshold <- 2;
	int numberOfGuestsInStage <- 0;

	int counter <- 0;
	
	init {
		create Guests number:NumberOfGuests {
			location <- {rnd(100), rnd(100)};
		}
		
		create Stages number: NumberOfStages {
			location <- StagesPosition[counter];
			StageColor <- StageColors[counter];
			counter <- counter + 1;
			
		}
	}
	
}


species Stages skills: [fipa]{
	
	
	rgb StageColor;
//	bool IsCrowded <- false;
	string EventInThisStage;
	list<int> StageValues;
	
	aspect default {
			draw circle(3.5) at: location color: StageColor depth: 5.0 lighted: true;
			draw cone3D(3.5,4.0) at: (location - {0.0, 0.0, -5.0}) color: StageColor;
		
	}
	
		
	/*
	 * When each stage is hosting an act that last for a fixed time, give each
	 * act some attributes with different values
	 */	
	init {
		loop times: 6{
			StageValues << rnd(1, 20);
		}
	}
	
	
	reflex NewValues when: time mod 20 = 0{
		StageValues <- nil;
		loop times: 6 {
			StageValues << rnd(1, 20);
		}
	}
		
	reflex SendMyValues when: !empty(informs) {
		write ("\n/============ " + self.name + " Sends Values ===========/");
		Guests sender;
		loop InformationMessage over: informs {
			write (self.name + ": Guest " + InformationMessage.sender + " asked for my Values \n");
			do inform with:(message: InformationMessage, contents: [StageValues]);
		}
		informs <- nil;
	}
	
}


/*
 * ==================== Frist ==========================================
 * For every stage, the guest picks act based on his preferences
 * The music/band is not the deciding factor. There are more things that
 * the agent considers before choosing which act he would like to see
 * 
 * ==================== Second ==========================================
 * Each time an agent selects an act to see, make his decision based on
 * some sort of an utility function
 * 
 * ==================== Third ==========================================
 * Agent calculates his utility for each stage
 * The stage with the highest utility is picked!
 */
species Guests skills: [fipa, moving]{
	
	bool WantCrowd <- flip(0.5);
	Stages TargetStage <- nil;
	rgb GuestColor <- #pink;
	list<int> GuestValues <- nil;
	list<list<int>> StagesValues <- nil;
	bool StageValuesChanged <- false;
	list<int> UtilityForEachStage <- nil;
	
//	Visual aspect
	aspect default{
		draw sphere(1) at: (location - {2.0, 0.0, -1.5}) color:GuestColor;
		draw pyramid(2) at: (location - {2.0, 0.0, 0.0}) color:GuestColor;
	}
	
	reflex MoteToTargetStage when: self.TargetStage != nil{
		do goto target: TargetStage speed: 2.5;
	}
	
	reflex MoveArrownd when: self.TargetStage = nil{
		do wander;
	}
	
	init {
		loop times: 6 {
			GuestValues << rnd(1, 20);
		}
	}
	
	reflex AskStageInformation when: time mod 20 = 0 {
		StagesValues <- nil;
		do start_conversation with:(to: list(Stages), protocol: 'fipa-request', performative: 'inform', contents: ["Send Informations"]);
		write ("\n/=========== " + self.name + " Want informations ============/");
		write (self.name + " Want to knwo the informations about the stages\n");
	}
	
	reflex GuestReceiveValues when: !empty(informs) {
		write ("\n/============= Guest " + self.name + " receive Information message ==================/");
		loop InformationMessage over: informs {
			StagesValues << InformationMessage.contents[0];
			write ("I " + self.name + " received new values for " + InformationMessage.sender + "\n");
		}
		StageValuesChanged <- true;
		informs <- nil;
	}
	
	reflex FindMostLikedStage when: StageValuesChanged {
		write ("\n============ Find the Best Stage for the Guest " + self.name + " =====================/");
		StageValuesChanged <- false;
		UtilityForEachStage <- [0, 0, 0, 0];
		
		loop stage from: 0 to: length(Stages) - 1 {
			loop value from: 0 to: length(StagesValues) - 1{
				list<int> IndexStageValues <- StagesValues[stage];
				UtilityForEachStage[stage] <- UtilityForEachStage[stage] + IndexStageValues[value] * self.GuestValues[value]; 
			}
		}
		write ("Utility For Each Stage: " + UtilityForEachStage);
		
		int MaxUntility <- max(UtilityForEachStage);
		
		write ("The max unitility from all stagies is: " + MaxUntility);
		
		loop Utility from: 0 to: length(UtilityForEachStage) - 1 {
			if (MaxUntility = UtilityForEachStage[Utility]){
				self.TargetStage <- StagesPosition[Utility];
				self.GuestColor <- StageColors[Utility];
			}
		}
		
	}
	
	
	
}

experiment main type: gui{
	
	output{
		display map type: opengl{
			species Stages;
			species Guests;
		}
		
	}
	
}