/**
* Name: NewFestival
* Based on the internal empty template. 
* Author: iosif
* Tags: 
*/


model NewFestival

/* Insert your model definition here */

global{
	

	int GuestsNumber <- 15;
	int InformationCenterNumber <- 1;
	int FoodStoresNumber <- 3;
	int BeverageStoresNumber <- 3;
	int GeneralStoresNumber <- 3;
	int SellersNumber <- 1;
	
	
//	Initialising Part	
	init{
		
//		Guest Initialising
		create Guests number: GuestsNumber{
			location <- {rnd(100), rnd(100)};
			speed <- 1.0;
		}
		
//		Information Center Initialising
		create InformationCenter number: InformationCenterNumber{
			location <- {50, 50};
		}
		
//		Food Store Initialising
		create FoodStores number: FoodStoresNumber{
			location <- {rnd(100), rnd(100)};
		}
		
//		Beverage Store Initialising
		create BeverageStores number: BeverageStoresNumber{
			location <- {rnd(100), rnd(100)};
		}
		
//		General Store Initialising
		create GeneralStores number: GeneralStoresNumber{
			location <- {rnd(100), rnd(100)};
		} 
		
//		Seller Initialising
		create Sellers number: SellersNumber{
			location <- {rnd(100), rnd(100)};
		}
	}	 
		
}

// Creation of Guest
species Guests skills:[moving] {
	
//	Initial Guest's Variables 
	float thirst <- rnd(50) + 50.0;
	float hunger <- rnd(50) + 50.0;
	bool needFood <- false;
	bool needBeverage <- false;	
	rgb GuestColor <- #pink;
//	Guest's targets
	InformationCenter InformationCenterTarget;
	FoodStores FoodSroteTarget;
	BeverageStores BeverageStoreTarget;
	GeneralStores GeneralStoreTarget;
	Sellers SellerTarget;
	
//	Visual aspect
	aspect default{ draw sphere(1) color:GuestColor ;}
	
		
}


// Creation of Information Center
species InformationCenter{
	
	rgb InformationCenterColor <- #gold;
	
// Visual aspect
	aspect default{draw cube(7) color: InformationCenterColor;}

}

// Creation of Seller
species Sellers {
	
	rgb SellerColor <- #grey;
	
//	Visual aspect
	aspect default{ draw sphere(1) color:SellerColor;}
}

// Creation of Food Store
species FoodStores {
	
	rgb FoodStoreColor <- #green;

//	Visual aspect
	aspect default{ draw cone3D(3.5,4.0) color:FoodStoreColor;}
	
}

// Creation of Beverage Store
species BeverageStores {
	
	rgb BeverageStoreColor <- #blue;
	
//	Visual aspect
	aspect default{ draw pyramid(5) color: #blue;}
	
}

// Creation of General Store
species GeneralStores {
	
	rgb GeneralStoreColor <- #black;
	
	aspect default{ draw cone3D(3.5,4.0) color: #black;}
	
}


// GUI part
experiment main type: gui{
	
	output{
		display map type: opengl{
			species Guests;
			species FoodStores;
			species BeverageStores;
			species InformationCenter;
			species GeneralStores;
			species Sellers;
		}
	}
}