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
	int GeneralStoreNumber <- 3;
	int distanceThreshold <- 2;
	

	
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
		
//		General shops stores
		create GeneralStore number: GeneralStoreNumber{
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
	FoodStore FoodSroteTarget;
	BeverageSore BeverageStoreTarget;
	GeneralStore GeneralStoreTarget;
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
	reflex CountHungryAndThirsty when: needBeverage=false and needFood=false{
		thirst <- thirst-rnd(4);
		hunger <- hunger-rnd(4);
		if(target=nil and (thirst < 30 or hunger<30)){
			if (thirst < 30 and hunger < 30 ){
			    write name + " is hungry and thursty";
				needFood <- true;
				needBeverage <- true;
				color <- #black;
				target <- one_of(InformationCenter);
			}else if(hunger < 30){
				write name + " is hungry";
				needFood <- true;
				color <- #green;
				target <- one_of(InformationCenter);
			}else{
				write name + " is thirsty";
				needBeverage <- true;
				color <- #blue;
				target <- one_of(InformationCenter);
			}
			
		}
	}
	
	reflex moveArround when: target=nil and needFood=false and needBeverage=false{
		do wander;
	}
	
//	reflex moveToInformationCenter when: target != nil{
//		do goto target: target;
////		.init.InformationCenter.location;
//	}
	
	reflex GoToInfoCenter when: target != nil and BeverageStoreTarget=nil and GeneralStoreTarget=nil and FoodSroteTarget=nil{
		do goto target: target.location;
	}
//	
//	Asking part for informations
	reflex AskForInformations when: target != nil and (thirst < 30 or hunger < 30){
		ask InformationCenter at_distance distanceThreshold{
//			write "Beverage Stores" + self.BeverageSores;
			if (myself.needFood = true and myself.needBeverage = true){
				write "Where is a food store and a beverage store ?";
//				myself.FoodSroteTarget <- (1 among self.FoodSotres)[1];
				myself.GeneralStoreTarget <- one_of(self.GeneralStores);
				myself.target <- nil;
			}else if(myself.needFood = true){
				myself.FoodSroteTarget <- one_of(self.FoodSotres);
				myself.target <- nil;
				write "Where is a food store ?";
			}else if (myself.needBeverage = true){
				myself.BeverageStoreTarget <- one_of (1 among (self.BeverageSores));
				myself.target <- nil;
				write myself.name + " Where is a beverage store ?" + myself.BeverageStoreTarget + "  " + self.BeverageSores + " " + myself.needBeverage;
			}			
		}

	}
	
	reflex MoveToBeverageStore when: BeverageStoreTarget != nil{
		write "Ready for beverage " + BeverageStoreTarget.location + " " + target;
		do goto target: BeverageStoreTarget;
	}
	
	reflex MoveToGeneralStore when: GeneralStoreTarget != nil{
		write "Ready for everything " + GeneralStoreTarget.location + " " + target;
		do goto target: GeneralStoreTarget;
	}
	
	reflex MoveToFoodStore when: FoodSroteTarget != nil{
		write "Ready for food " + FoodSroteTarget.location + " " + target;
		do goto target: FoodSroteTarget;
	}
	
	reflex ReachTheStoreFood when: !empty(FoodStore at_distance distanceThreshold) {
		needFood <- false;
		hunger <- 100.0;
		FoodSroteTarget <- nil;
		 color <- #pink;
		write name + " got food";
	}
	
	reflex ReachTheStoreBeverage when: !empty(BeverageSore at_distance distanceThreshold) {
		needBeverage <- false;
		thirst <- 100.0;
		BeverageStoreTarget <- nil;
		 color <- #pink;
		write name + " got beverage";
	}
	
	reflex ReachTheStoreGeneral when: !empty(GeneralStore at_distance distanceThreshold) {
		needBeverage <- false;
		needFood <- false;
		thirst <- 100.0;
		hunger <- 100.0;
		GeneralStoreTarget <- nil;
		color <- #pink;
		write name + " got everything";
	}
}

// Information Center implementation
species InformationCenter{
	
	aspect default{
		draw cube(7) color: #gold;
	}
	
// Create two lists of Food Stores and Beverage Stores
   list<FoodStore> FoodSotres;
//   list<BeverageSore> BeverageSores <- (BeverageSore at_distance 100);
   list<BeverageSore> BeverageSores;
   list<GeneralStore> GeneralStores;
	
	reflex listStoreLocations{
		ask FoodStore{
			write "Food store at:" + self.location; 
			myself.FoodSotres <- FoodStore;
		}	
		ask BeverageSore{
			write "Drink store at:" + self.location; 
			myself.BeverageSores <- BeverageSore;
		}ask GeneralStore{
			write "Drink and Food store at" + self.location;
			myself.GeneralStores <- GeneralStore;
		}
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

species GeneralStore{
	
	aspect default{
		draw cone3D(3.5,4.0) color: #black;
	}
} 

experiment main type: gui{
	
	output{
		display map type: opengl{
			species Guest;
			species FoodStore;
			species BeverageSore;
			species InformationCenter;
			species GeneralStore;
			species Entrance;
		}
	}
}

	


