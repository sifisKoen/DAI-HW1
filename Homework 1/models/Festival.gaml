/**
* Name: Festival
* Based on the internal empty template. 
* Author: iosif
* Tags: 
*/


model Festival


// First we create the global

global{
	
	// The Values
	int InformationCenterNumber <- 1;
	int GuestNumber <- 15;
	int FoodStoreNumber <- 3;
	int BeverageStoreNumber <- 3;
	

	
	init{
		
		// Just an entrance for the festival
		create Entrance number: 1{
			location <- {1, 50, 0};
		}
		
		// The information center of the festival
		create InformationCenter number: InformationCenterNumber{
//		 InformationCenter position on the map
			location <- {50, 50};		
		}
		
		// The guests
		create Guest number: GuestNumber{
			location <- {rnd(100), rnd(100)};
			speed <- 1.0;			
		}
		
		// The Food stores
		create FoodStore number: FoodStoreNumber{
			location <- {rnd(100), rnd(100)};
		}
		
		// The beverage stores		
		create BeverageSore number: BeverageStoreNumber{
			location <- {rnd(100), rnd(100)};			
		}
		
	}
	
}

// Guest implementation
species Guest skills:[moving]{
	
	float thirst <- rnd(50) + 50.0;
	float hunger <- rnd(50) + 50.0;
	bool needFood <- false;
	bool needBeverage <- false;
//	InformationCenter target <- nil;
	InformationCenter target;
	rgb color <- #pink;
	
//	Visual aspect
	aspect default{
		draw sphere(1) color:color;
	}
	
	
/* In this reflex we check if the agent is thirsty of hungry
 * Colors for each situation:  
 * 		black -> if our agent is hungry AND thirsty
 * 		green -> if our agent is hungry
 * 		blue -> if out agnet is thirsty
 */
	reflex CountHungryAndThirsty{
		thirst <- thirst-rnd(4);
		hunger <- hunger-rnd(4);
		if(target=nil and (thirst < 30 or hunger<30)){
			if (thirst < 30 and hunger < 30 ){
			    string agentMessage <- name + " is hungry and thursty";
				needFood <- true;
				needBeverage <- true;
				color <- #black;
			}else if(hunger < 30){
				string agentMessage <- name + " is hungry";
				needFood <- true;
				color <- #green;
			}else{
				string agentMessage <- name + " is thirsty";
				needBeverage <- true;
				color <- #blue;
			}
			
			target <- one_of(InformationCenter);
			write "hello";	
		}
	}
	
	reflex moveArround when: target= nil{
		do wander;
	}
	
	reflex moveToInformationCenter when: target != nil{
		do goto target: target;
//		.init.InformationCenter.location;
	}
	
	reflex AskForInformations when: target != nil{
		if (needFood = true and needBeverage = true){
			write "Where is a food store and a beverage store ?";
		}else if(needFood = true){
			write "Where is a food store ?";
		}else{
			write "Where is a beverage store ?";
		}
	}
}

// Information Center implementation
species InformationCenter{
	
	aspect default{
		draw cube(7) color: #gold;
	}
}

// Food Store implementation
species FoodStore{
	
	bool hasFood <- true;
	
	aspect default{
		draw cone3D(3.5,4.0) color: #green;
	}
}

// Beverage Store implementation
species BeverageSore{
	
	bool hasBeverage <- true;
	
	aspect default{
		draw pyramid(5) color: #blue;
	}
}

species Entrance{
	
	aspect dafualt{
		draw box(10, 5, 5) at:location color: #gray;
	}
}

experiment main type: gui{
	
	output{
		display map type: opengl{
			species Guest;
			species FoodStore;
			species BeverageSore;
			species InformationCenter;
			species Entrance;
		}
	}
}

	


