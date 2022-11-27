/**
* Name: AuctionFestival
* Based on the internal empty template. 
* Author: iosif
* Tags: 
*/


model AuctionFestival

/* Insert your model definition here */

global{
	
	int GuestsNumber <- 15;
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
int GuestMinimumAcceptancePrice <- 19;
int GuestMaximumAcceptancePrice <- 40; 
	
	//	Initialisation Part
	init{
		
//		Guest Initialising
		create Guests number: GuestsNumber{
			location <- {rnd(100), rnd(100)};
			speed <- 1.0;
		}
		
//		Seller Initialising
		create Sellers number: SellersNumber{
			location <- {rnd(100), rnd(100)};
		}
	}	
	
}
	

// Creation of Guest
species Guests skills: [moving, fipa]{
	
	rgb GuestColor <- #pink;
	
	bool WantClothe <- false;
	bool WantToy <- false;
	bool WantAccessories <- false;
	

	bool WantToParticipateToDutchAuction <- false;
	
//	A list for those who want to participate to Dutch auction
	list<Guests> DutchAuctionInterestedGuests;
	
//	Guest moving target
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
	reflex MoveArround when: SellerTarget = nil{	
		do wander;
	}
	
	
	reflex MoveToSeller when: SellerTarget != nil{
		write "Ready to buy: " + ItemWantToBuy + " going to " + SellerTarget.location;
	}
//	End of Moving Reflexes

	
//	Guest Receive the CFP message from Seller
	reflex GuestReceiveTheCFPMessage when: !empty(cfps){
		
		message SellerProposals <- (cfps at 0);

//		Consol logs
		write "/=======================================" + self.name  + "=================================================================================/";
		write "I : " + self.name + " received a proposal from " + SellerProposals.sender + " the proposal was: " + SellerProposals.contents;
		write "		I want to buy " + self.ItemWantToBuy + " and I want to participate to an " + self.AuctionWantToParticipate + " auction";
		
		if (SellerProposals.contents[0] = "Start" and SellerProposals.contents[1] = self.ItemWantToBuy and SellerProposals.contents[3] = self.AuctionWantToParticipate){
			
			GuestColor <- #olive;
			
//			Acceptance consol logs
			write "I " + self.name + " want to participate to the auction of " + SellerProposals.sender;
			write "		The proposal I reaceive and I accept is : " + SellerProposals.contents ;
			write "/========================================================================================================================/";
			
//			DutchAuctionInterestedGuests <- Guests;
			
//			do propose message: SellerProposals contents: ["Ok. That sound interesting I want to participate"] ;

			do GuestReplyToCfpSellersMessagelForDutchAuction (SellerProposals, int (SellerProposals.contents[2]));
		}else{ 
//		(SellerProposals.contents[1] != self.ItemWantToBuy or SellerProposals.contents[3] != self.AuctionWantToParticipate){

//			Rejection consol logs
			write "I " + self.name + " don't want to participate to the auction of " + SellerProposals.sender ;
			write "		I want: " + self.ItemWantToBuy + " but the seller sells: " + SellerProposals.contents[1];
			write "     I want: " + self.AuctionWantToParticipate + " but the seller starts: " + SellerProposals.contents[3];
			write "/========================================================================================================================/";
		
		}
	}
	
//	In this action (Function) the Guest sends reply to the Seller with a new propose. 
	action GuestReplyToCfpSellersMessagelForDutchAuction (message SellerProposals, int SellersPrice) {
		
		write "\n ==========================Action GuestReplyToCfpSellersMessagelForDutchAuction log out put for " + self.name +" ==========================\n  
				In action we have : A SellerProposals :" + SellerProposals.contents + " with a starting price of: " + SellersPrice;
		if (int(SellerProposals.contents[2]) > self.GuestAcceptedPrice){
//			A message from buyer to Seller that can not afford the money
			write "==============================Not aford Reply from " + self.name + "==============================";
			write "\n I " + self.name + " can not afford these money I have only " + self.GuestAcceptedPrice + "\n But the " + SellerProposals.sender + " sells the item :" + SellerProposals.contents[2] + "\n";
			
//			Guest send a refuse message to Seller
			do propose message: SellerProposals contents: ["I can not afford these money please do something better", self.GuestAcceptedPrice] ;
		}
		
	}
	
	
	reflex read_accept_proposals when: !(empty(reject_proposals)) {
		write name + ' receives reject_proposal messages';
		loop i over: reject_proposals {
			write 'reject_proposal message with content: ' + string(i.contents);
		}
	}
	
}


species Sellers skills: [moving, fipa]{
	
	rgb SellerColor <- #grey;
	
	bool AnnouncedAnAuction <- false;
	bool AuctionIsRunning <- false;
	bool WeHaveAWinner <- false;
	
	list<Guests> GuestsWhoWantsDutchAuction <- nil;
	
	string SellingItem;
	
//	A random Auction for the sellers
	string SellersAuction <- TypeOfAuction[rnd(length(TypeOfAuction) - 1)];
	
	int SellerItemPrice;
	
	int NewItemPrice;
	int OldItemPrice;
	
//	Visual aspect
	aspect default{ 
		draw sphere(1) at: (location - {2.0, 0.0, -1.5}) color:SellerColor;
		draw pyramid(2) at: (location - {2.0, 0.0, 0.0}) color:SellerColor;	
		
		if (SellersAuction = "Dutch"){
			draw "Seller: " + name + " Starts " + SellersAuction + " Auction and sells " + SellingItem at: location + {0, 0, 0} color: #green font: font("Arial", 10, #bold) perspective: false;
		}			
	}
	 
	reflex SellerStartsAnAuction when: AnnouncedAnAuction = false and AuctionIsRunning = false and SellersAuction != nil{
		
		SellingItem <- SellersItemsAvailable[rnd(length(SellersItemsAvailable) - 1)];
		SellerItemPrice <- rnd(SellerMinimunItemPrice, SellerMaximumItemPrice);
		write  "Start of the auction: I " + self.name + " started and auction type of: " +  self.SellersAuction + ", my Item for selling is: " + SellingItem + " and the price is: " + SellerItemPrice; 
		
//		Seller sends an CFP broadcast message to all Guests 
		if (SellersAuction = "Dutch"){
			do start_conversation to: list(Guests) protocol: 'fipa-propose' performative: 'cfp' contents: ["Start", SellingItem, SellerItemPrice, SellersAuction];
			AnnouncedAnAuction <- true;
			AuctionIsRunning <- true;
		}
	}
	
	
	reflex SellerReceiveProposeMessage when: !empty(proposes){
		
//		write "(Time " + time + "): " + self.name + " receives propose messages";

//		Consol log from Seller when receives a new propose message
		write "\n /====================== New proposes from " + self.name + " ============================/";
		write "\n I " + self.name + " Received a proposal massage at time: " + "( Time " + time + ")\n/================================================================================================/\n";
		
		message GuestProposal <- proposes at 0;
		
		loop proposer over: proposes{
			
			write "I " + self.name + " received a rejection message from " + proposer.sender + " and it says that: " + proposer.contents[0] + " and its money are: " + proposer.contents[1] + " euros\n";
			
			if (int(proposer.contents[1]) < SellerMinimunItemPrice){
				
				write "I " + self.name + " can not acept" + proposer.sender + "on my auction you have very fiew money \nMy minimum price is: " + SellerMinimunItemPrice + " but you have only: " + proposer.contents[1] + " euros \n";
				write "/====================== End  ============================/";
//				TODO: We need to make a  do reject_proposal message: proposer
				
				do reject_proposal message: GuestProposal contents: ['No! It \'s too cold today!'] ;
				
			}else if(int(proposer.contents[1]) < SellerItemPrice){
				
				write "/====================New Price===================================/";
				write "Ok I " + self.name +" can do something better for you " + proposer.sender;
				
//				We make this so do not reduse each time the money
				if (NewItemPrice = self.SellerItemPrice){
					self.SellerItemPrice <- NewItemPrice;
				}else{
					self.SellerItemPrice <- self.SellerItemPrice - int(rnd(1, 3));
					NewItemPrice <- self.SellerItemPrice; 	
				}
				
//				We check the new price
				do CheckTheItemPrice(self.SellerItemPrice, self.NewItemPrice);
				
				write "The new item price is: " + self.SellerItemPrice + "\n";
				
//				TODO: We need to make the do refuse message: proposers

//				do refuse message: proposer contents: [NewItemPrice] ;
				
				write " /====================== End  ============================/";
				

				
			}else if((int(proposer.contents[1]) = self.NewItemPrice) or (int(proposer.contents[1]) > self.NewItemPrice)){
				
				write "We have winner !!! The: " + proposer.sender + " now you can come to :" + self.location + " location to to take your " + self.SellingItem;
				write "\n /====================== End  ============================/";
//				TODO: We need to make the do accept_proposal message: proposers
				
			}
		
		}	
	}
	
	
	
//	An action so to check if the Item price droped down from the Sellers minimum axeptable price
	action CheckTheItemPrice(int SellerItemPrice, int NewItemPrice){
		if (SellerItemPrice < SellerMinimunItemPrice){
			SellerItemPrice <- SellerMinimunItemPrice;
			NewItemPrice <- SellerItemPrice;
			write "";
		}
	}
	
}




// GUI part
experiment main type: gui{
	
	output{
		display map type: opengl{
			species Guests;
			species Sellers;
		}
	}
}



	