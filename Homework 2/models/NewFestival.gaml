/**
* Name: NewFestival
* Based on the internal empty template. 
* Author: iosif, Sofia
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

//	------------Create Some Lists as global variables------------
//  A list with items witch sellers sell
	list<string> SellersItemsAvailable <- ["clothes", "accessories", "toys"];
//	Create a list of auction type so to pick an auction
	list<string> TypeOfAuction <- ["Dutch"];	

// ------------Dutch Auction Variables------------
	
//	Create a minimun and a maximum starting price for the items
int SellerMinimunItemPrice <- 20;
int SellerMaximumItemPrice <- 50;
// Create a minimum and a maximum acceptance price for the guest
int GuestMinimumAcceptancePrice <- 10;
int GuestMaximumAcceptancePrice <- 30; 
	
	
	
	
//	Initialisation Part
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
species Guests skills:[moving, fipa] {
	
//	Initial Guest's Variables 
	float thirst <- rnd(50) + 50.0;
	float hunger <- rnd(50) + 50.0;
	bool needFood <- false;
	bool needBeverage <- false;	
	
	bool wantsToy <- false;
	bool wantsClothe <- false;
	rgb GuestColor <- #pink;
//	Guest's targets
	InformationCenter InformationCenterTarget;
	FoodStores FoodSroteTarget;
	BeverageStores BeverageStoreTarget;
	GeneralStores GeneralStoreTarget;
	Sellers SellerTarget;

//	Create a variable to check if the agent won the auction
	bool AuctionWin <- false;

//	Selection of a new random item
	string ItemWantToBuy <- SellersItemsAvailable[rnd(length(SellersItemsAvailable) - 1)];
	
//	Whitch is the type of auction the Guest wants to participate
	string AuctionWantToParticipate <- TypeOfAuction[rnd(length(TypeOfAuction) - 1)];
	
//	Create a random accepted price for each Guest so to take place to the auction
	int  GuestAcceptedPrice <- rnd(GuestMinimumAcceptancePrice, GuestMaximumAcceptancePrice);
	
//	Visual aspect
	aspect default{ 
		draw sphere(1) at: (location - {2.0, 0.0, -1.5}) color:GuestColor;
		draw pyramid(2) at: (location - {2.0, 0.0, 0.0}) color:GuestColor;
		
		if AuctionWin = true{
			draw sphere(0.9) at: (location - {0.5, 0.0, -0.8}) color:GuestColor;
		}
	}
	
//	Moving Reflexes
	reflex MoveArround when: InformationCenterTarget = nil and FoodSroteTarget = nil and BeverageStoreTarget = nil and GeneralStoreTarget = nil and  SellerTarget = nil{	
		do wander;
	}
	
	reflex MoveToBeverageStore when: BeverageStoreTarget != nil{
		write "Ready for beverage. I am going to " + BeverageStoreTarget.location;
		do goto target: BeverageStoreTarget;
	}
	
	reflex MoveToGeneralStore when: GeneralStoreTarget != nil{
		write "Ready for everything. I am going to " + GeneralStoreTarget.location;
		do goto target: GeneralStoreTarget;
	}
	
	reflex MoveToFoodStore when: FoodSroteTarget != nil{
		write "Ready for food. I am going to " + FoodSroteTarget.location;
		do goto target: FoodSroteTarget;
	}
	
	reflex MoveToSeller when: SellerTarget != nil{
		write "Ready to buy: " + ItemWantToBuy + " going to " + SellerTarget.location;
	}
	
	list<Guests> InterestedGuests;
	
	reflex GuestReceivesCfpMessageFromInitiator when: !empty(cfps) {
		message ProposalFromSeller <- (cfps at 0);
//		write "Proposals " + ProposalFromSeller;
		if (ProposalFromSeller.contents[0] = "Start" and ProposalFromSeller.contents[1] = ItemWantToBuy and ProposalFromSeller.contents[3] =  AuctionWantToParticipate){
			write self.name + " want to participate to " + agent(ProposalFromSeller.sender)+ " Auction with money" + self.GuestAcceptedPrice;
			GuestColor <- #olive;
			InterestedGuests <+ self;
//			write "proposal from seller price " + ProposalFromSeller.contents[2];
//			write  self.name + " I have these money " + self.GuestAcceptedPrice;
			do GuestReplyToCfpSellersMessagelForDutchAuction (ProposalFromSeller, int (ProposalFromSeller.contents[2]));
		}else if (ProposalFromSeller.contents[0] = "Start" and (ProposalFromSeller.contents[1] != ItemWantToBuy or ProposalFromSeller.contents[3] !=  AuctionWantToParticipate)){
//			write "Suggested " + ProposalFromSeller.contents[1] + "but I want " + ItemWantToBuy;
			do refuse message: ProposalFromSeller contents: ["I don't want to participate"];
//			write "I " + self.name + " don't want to participate to " + ProposalFromSeller.sender + " Auction";
		}else if (ProposalFromSeller.contents[0] = "Stop"){
			write "Stopped guest";
			GuestColor <- #pink;
		}
	}
	
	
	action GuestReplyToCfpSellersMessagelForDutchAuction (message ProposalFromSeller, int SellersPrice) {
		
//		write ProposalFromSeller.contents;
//		write "The price is: " + SellersPrice;
		if ( GuestAcceptedPrice < SellersPrice ){		
			do refuse message: ProposalFromSeller contents: ["I can not buy this"];
		}else if (GuestAcceptedPrice >= SellersPrice ){
			do accept_proposal with: (message: ProposalFromSeller, contents: ["I, " + name + ", accept your offer of " + SellersPrice ]);
			write self.name + " accepts proposal";
//			do start_conversation to: list(Sellers) protocol: 'fipa-propose' performative: 'cfp' contents: ["I, " + name + ", accept your offer of " + SellersPrice];
//			AuctionWin <- true;
		}
	}
//	
	
	
/** 
 * Colors change depends on what item guest want to buy
 * 		
 * 		Colors for each situation
 * 			Brown = clothes 
 * 			Silver = accessories
 * 			Tan = toys
 * 
 */
	reflex AuctionWin when: AuctionWin = true{
		if (ItemWantToBuy= "clothes"){
			
			GuestColor <- #brown;
			
			do goto target: SellerTarget;
			
		}else if (ItemWantToBuy = "accessories"){
			
			GuestColor <- #silver;
			
		}else if (ItemWantToBuy = "toys"){
			
			GuestColor <- #tan;
			
		}
	}
	
	
	
}


// Creation of Information Center
species InformationCenter{
	
	rgb InformationCenterColor <- #gold;
	
// Visual aspect
	aspect default{draw cube(7) color: InformationCenterColor;}

}

// Creation of Seller
species Sellers skills:[moving, fipa] {
	
	bool AnnouncedAnAuction <- false;
	bool AuctionIsRunning <- false;
	bool WeHaveAWinner <- false;
	
	list<Guests> InterestedGuests;
	
	rgb SellerColor <- #grey;
	
	
	string SellingItem;
	
//	A random Auction for the sellers
	string SellerStartsAuction <- TypeOfAuction[rnd(length(TypeOfAuction) - 1)];
	
	int SellerItemPrice;
	
//	Visual aspect
	aspect default{ 
		draw sphere(1) at: (location - {2.0, 0.0, -1.5}) color:SellerColor;
		draw pyramid(2) at: (location - {2.0, 0.0, 0.0}) color:SellerColor;	
		
		if (SellerStartsAuction = "Dutch" and time >= 10){
			draw "Seller: " + name + " Starts " + SellerStartsAuction + " Auction and sells " + SellingItem at: location + {0, 0, 0} color: #green font: font("Arial", 10, #bold) perspective: false;
		}			
	}
	 
//	 The Seller Starts the Auction
	reflex AuctionStarting when: SellerStartsAuction != nil and AnnouncedAnAuction = false and AuctionIsRunning = false and WeHaveAWinner = false{
		
		SellingItem <- SellersItemsAvailable[rnd(length(SellersItemsAvailable) - 1)];
		SellerItemPrice <- rnd(SellerMinimunItemPrice, SellerMaximumItemPrice);
		write  "Start of the auction: " + self.name + " " +  self.SellerStartsAuction + " " + SellerItemPrice; 
		
		if (SellerStartsAuction = "Dutch"){
			do start_conversation to: list(Guests) protocol: 'fipa-propose' performative: 'cfp' contents: ["Start", SellingItem, SellerItemPrice, SellerStartsAuction];
			AnnouncedAnAuction <- true;
			AuctionIsRunning <- true;
		}
	}
	
	
//	The Seller receives Reject Message
	reflex ReceiveRejectCfpMessages when: AuctionIsRunning and !empty(refuses) and SellerStartsAuction = "Dutch"{
					
			write name + ' receives reject messages';
	
			self.SellerItemPrice <- self.SellerItemPrice - 1;// rnd(1, 2);
			
			if(SellerItemPrice < SellerMinimunItemPrice){
				AuctionIsRunning <- false;
				AnnouncedAnAuction <- false;
				write name + " price went below minimum value (" + SellerMinimunItemPrice + "). ";
				do start_conversation to: list(Guests) protocol: 'fipa-propose' performative: 'cfp' contents: ["Stop", SellerItemPrice];
//				cfps <- nil;
//				do refuse message: proposalFromInitiator contents: ['I am busy today'] ;
			} else {
				do start_conversation to: list(Guests) protocol: 'fipa-propose' performative: 'cfp' contents: ["Continue", SellerItemPrice];
			}
	}
	
	
//	The Seller Receive Accept Message
	reflex ReceiveAcceptCfpMessages when: AuctionIsRunning and !empty(accept_proposals) and SellerStartsAuction = "Dutch"{
			write name + ' receives accept messages';
			
			loop accepted over: accept_proposals {
				write name + ' got accepted by ' + accepted.sender + ': ' + accepted.contents;
				if(WeHaveAWinner = false){
					write "The winner " + accepted.sender;
					do accept_proposal message: accepted.sender contents: ["Stop","Winner"];
					do start_conversation to: list(Guests) protocol: 'fipa-propose' performative: 'cfp' contents: ["Stop"];
					WeHaveAWinner <- true;
					AuctionIsRunning <- false;
					AnnouncedAnAuction <- false;
					write "The auction is finished";
				}
			}
			
	}
	
	
}

// Creation of Food Store
species FoodStores {
	
	rgb FoodStoreColor <- #green;

//	Visual aspect
	aspect default{ 
		draw circle(3.5) color: FoodStoreColor depth: 5.0 lighted: true;
		draw cone3D(3.5,4.0) at: (location - {0.0, 0.0, -5.0}) color:FoodStoreColor;
	}
	
}

// Creation of Beverage Store
species BeverageStores {
	
	rgb BeverageStoreColor <- #blue;
	
//	Visual aspect
	aspect default{ 
		draw cube(5) at: (location - {2.0, 0.0, 0.0})  color: BeverageStoreColor lighted: true;
		draw pyramid(5) at: (location - {2.0, 0.0, -5.0}) color: BeverageStoreColor;
	}
	
}

// Creation of General Store
species GeneralStores {
	
	rgb GeneralStoreColor <- #black;
	
	aspect default{ 
		draw circle(3.5) color: GeneralStoreColor depth: 5.0 lighted: true;
		draw cone3D(3.5,4.0) at: (location - {0.0, 0.0, -5.0}) color: GeneralStoreColor;
	}
	
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