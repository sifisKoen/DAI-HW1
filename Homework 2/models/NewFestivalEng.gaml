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
	list<string> TypeOfAuction <- ["English"];	

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
	
//	Create a variable For England Auction Offer
	int EnglishAuctionGuestOffer;
	
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
	Sellers TargetSeller;
	
	reflex GuestReceivesCfpMessageFromInitiator when: !empty(cfps) {
		message ProposalFromSeller <- (cfps at 0);
		write "Proposals" + ProposalFromSeller;
		
		if (ProposalFromSeller.contents[0] = "Start" and ProposalFromSeller.contents[1] = ItemWantToBuy and ProposalFromSeller.contents[3] =  AuctionWantToParticipate){
			write self.name + " want to participate to " + agent(ProposalFromSeller.sender)+ " Auction";			
			GuestColor <- #orange;
			TargetSeller <- ProposalFromSeller.sender;
			TargetSeller.InterestedGuests <+ self;
			write "proposal from seller price " + ProposalFromSeller.contents[2];
			write  self.name + " I have these money " + self.GuestAcceptedPrice;
		}else if (ProposalFromSeller.contents[0] = "Start" and (ProposalFromSeller.contents[1] != ItemWantToBuy or ProposalFromSeller.contents[3] !=  AuctionWantToParticipate)){
			write "Suggested " + ProposalFromSeller.contents[1] + "but I want " + ItemWantToBuy;
			do refuse message: ProposalFromSeller contents: ["I don't want to participate"];
			write "I " + self.name + " don't want to participate to " + ProposalFromSeller.sender + " Auction";
		}else if (ProposalFromSeller.contents[0] = "Stop"){
			GuestColor <- #pink;
			SellerTarget <- nil;
		}
	}
	
	
	reflex GuestReplyToCfpSellersMessagelForEnglishAuction when: AuctionWantToParticipate = "English" and !empty(cfps){
		
		message ProposalFromSeller <- (cfps at 0);
		int SellersPrice <- int (ProposalFromSeller.contents[1]);
		write ProposalFromSeller.contents;
		write "The current price is: " + SellersPrice;
				

		int CurrentBid <- int(ProposalFromSeller.contents[1]);
		if (GuestAcceptedPrice > CurrentBid) {
			
			int NewBid <- CurrentBid + rnd(1, 4);
			
			if(NewBid > GuestAcceptedPrice){
				
				NewBid <- GuestAcceptedPrice;
			}
			do start_conversation to: ProposalFromSeller.sender protocol: 'fipa-propose' performative: 'propose' contents: ["My new offer", NewBid];
			}else if (CurrentBid > GuestAcceptedPrice) {
			
				write name + ": The price is too hight I can not go further";
				do reject_proposal (message: ProposalFromSeller, contents: [" Price is too high I would like to withdraw"]);
		 		TargetSeller <- nil;
			}else if (ProposalFromSeller.contents[0] = "Winner") {
				ask Sellers{
					myself.AuctionWin <- true;
					write name + " won the auction for " + myself.ItemWantToBuy;
					myself.TargetSeller <- self.location;	
				}
			}	
	}

	
	
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
	
	
	string SellingItem <- SellersItemsAvailable[rnd(length(SellersItemsAvailable) - 1)];
	
//	A random Auction for the sellers
	string SellerStartsAuction <- TypeOfAuction[rnd(length(TypeOfAuction) - 1)];
	
	int SellerItemPrice <- rnd(SellerMinimunItemPrice, SellerMaximumItemPrice);
	
	int CurrentBid <- 0;
	string CurrentWinner <- nil;
	message Winner <- nil;

	
//	Visual aspect
	aspect default{ 
		draw sphere(1) at: (location - {2.0, 0.0, -1.5}) color:SellerColor;
		draw pyramid(2) at: (location - {2.0, 0.0, 0.0}) color:SellerColor;	
		
		if (SellerStartsAuction = "Dutch"){
			SellerColor <- #olive;
			draw "Seller: " + name + " Starts " + SellerStartsAuction + " Auction and sells " + SellingItem at: location + {-20, -4, -5} color: #olive font: font("Arial", 10, #bold) perspective: false;
		}else if(SellerStartsAuction = "English" and time >= 10){
			SellerColor <- #orange;
			draw "Seller: " + name + " Starts " + SellerStartsAuction + " Auction and sells " + SellingItem at: location + {-20, -4, -5}  color: #orange  font: font("Arial", 10, #bold) perspective: false;
		}
	}
	 
//	 The Seller Starts the Auction
	reflex AuctionStarting when: SellerStartsAuction != nil and AnnouncedAnAuction = false and AuctionIsRunning = false and WeHaveAWinner = false{
		write  self.name + " " +  self.SellerStartsAuction;
		
		if (SellerStartsAuction = "English"){
			do start_conversation to: list(Guests) protocol: 'fipa-propose' performative: 'cfp' contents: ["Start", SellingItem, SellerItemPrice, SellerStartsAuction];
			AnnouncedAnAuction <- true;
			AuctionIsRunning <- true;
			write InterestedGuests;
		}
	}
	
//	Get the English Auction messagies/proposes
	reflex GetEnglishProposes when: (!empty(proposes)) and SellerStartsAuction = "English"{
		
		if (SellerStartsAuction = "English"){
			
			loop GettingPropose over: proposes{
				write name + " got an offer from " + GettingPropose.sender;
				if(CurrentBid < int(GettingPropose.contents[1])){
					
					CurrentBid <- int(GettingPropose.contents[1]);
					CurrentWinner <- GettingPropose.sender;
					Winner <- GettingPropose;
				}
			
			}
//			do start_conversation to: Winner.sender protocol: 'fipa-propose' performative: 'cfp' contents: ["Winner"];
			write name + "sold the item " + SellingItem + " to " + CurrentWinner + " for: " + CurrentBid;
//			do accept_proposal with: (message: Winner, contents: ["You won the Biding the item is yours"]);
			do start_conversation to: InterestedGuests protocol: 'fipa-propose' performative: 'cfp' contents: ["Stop"];
		}
	}
	
//	The Seller receives Reject Message
	reflex ReceiveRejectCfpMessages when: AuctionIsRunning and !empty(reject_proposals) and SellerStartsAuction = "English"{
				
				
			loop RejectProposal over: reject_proposals{
				
				InterestedGuests >- RejectProposal.sender;
			}
			if (length(InterestedGuests) < 2){
				
				AuctionIsRunning <- false;
				
				if(CurrentBid < SellerMinimunItemPrice){
					
					write "No more auction";
				}else{
					write "We have a winner. The Winner is: " + CurrentWinner + " with the highest bid of: " + CurrentBid;
					do start_conversation to: Winner.sender protocol: 'fipa-propose' performative: 'cfp' contents: ['Winner']; 	
				}
				if(!empty(InterestedGuests)){
					do start_conversation to: InterestedGuests protocol: 'fipa-propose' performative: 'cfp' contents: ["Stop"];
				}
				InterestedGuests <- nil;
			}
	}	
			

	
	
//	The Seller Receive Accept Message
	reflex ReceiveAcceptCfpMessages when: AuctionIsRunning and !empty(proposes) and SellerStartsAuction = "Dutch"{
			write name + ' receives accept messages';
			
			loop accepted over: proposes {
				write name + ' got accepted by ' + accepted.sender + ': ' + accepted.contents;
				if(WeHaveAWinner = false){
				write "The winner" + accepted.sender;
				do accept_proposal message: accepted.sender contents: ["Stop","Winner"];
				WeHaveAWinner <- true;
				}
				
			}
//			auctionRunning <- false;
	}
	
	reflex SendEnglishAuctionInfo when: AuctionIsRunning and !empty(InterestedGuests) and SellerStartsAuction = "English"{
		
		write "The current bid for the English auction is: " + CurrentBid + ". So to win offer more!!";
		do start_conversation to: InterestedGuests protocol: 'fipa-propose' performative: 'cfp' contents: ["Bid For English"];
		
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