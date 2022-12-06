/**
* Name: FipaContractNetProtocol
* Based on the internal empty template. 
* Author: iosif
* Tags: 
*/


model NewAuctionTry

global {
	
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
	
	int numberOfBidders <- 5;	
	
	init {
		create Seller number: SellersNumber{
			location <- {rnd(100), rnd(100)};
		}
		create Guests number: GuestsNumber{
			location <- {rnd(100), rnd(100)};
//			speed <- 1.0;
		}
	}
}



species Seller skills: [fipa] {
	
	rgb SellerColor <- #grey;
		
	bool AnnouncedAnAuction <- false;
	bool AuctionIsRunning <- false;
	bool WeHaveAWinner <- false;
	
	string SellingItem;
	
	int NewItemPrice;
	
//	A random Auction for the sellers
	string SellersAuction <- TypeOfAuction[rnd(length(TypeOfAuction) - 1)];
	
	int SellerItemPrice;
	
	
	//	Visual aspect
	aspect default{ 
		draw sphere(1) at: (location - {2.0, 0.0, -1.5}) color:self.SellerColor;
		draw pyramid(2) at: (location - {2.0, 0.0, 0.0}) color:self.SellerColor;	
		
		if (self.SellersAuction = "Dutch"){
			SellerColor <- #olive;
			draw "Seller: " + name + " Starts " + self.SellersAuction + " Auction and sells " + self.SellingItem at: location + {-20, -4, -5} color: #olive font: font("Arial", 10, #bold) perspective: false;
		}
	}
	 
	 		
	reflex sendProposalToAllBidders when: (time = 1) {
			
		SellingItem <- SellersItemsAvailable[rnd(length(SellersItemsAvailable) - 1)];
		SellerItemPrice <- rnd(SellerMinimunItemPrice, SellerMaximumItemPrice);
		
		write "\n\n\n/========================================================================================================================/";
		write  "Start of the auction: I " + self.name + " started an auction type of: " +  self.SellersAuction + ", my Item for selling is: " + SellingItem + " and the price is: " + SellerItemPrice + "\n"; 
		write '(Time ' + time + '): ' + name + ' sent a public message to all bidders.';
		
		if(SellersAuction = "Dutch"){
			do start_conversation to: list(Guests) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Start", SellingItem, SellerItemPrice, SellersAuction] ;	
		}
	}
	
	reflex receive_refuse_messages when: !empty(refuses) {
		loop refuseMsg over: refuses {
			write '(Time ' + time + '): ' + agent(refuseMsg.sender).name + ' refused.';
			write "The Guest says: " + refuseMsg.contents;
			
			// Read content to remove the message from refuses variable.
//			string dummy <- refuseMsg.contents;
		}
	}
	
	reflex recieveProposals when: !empty(proposes) {
		int length <- length(proposes);
	
		int temp <- 0;
		message final_msg;
		string TheWinner;
		
		loop proposeMessage over: proposes {
			
			if(int(proposeMessage.contents[0]) < SellerMinimunItemPrice){
				write "\nWell " + proposeMessage.sender + " you don't have enough money to participate";
				do reject_proposal message: proposeMessage contents: ["Sorry", 0];	
			}else{
				
					if (temp < int(proposeMessage.contents[0])){
//						write "\n" + proposeMessage.sender + " has money " + proposeMessage.contents[0];
						temp <- int(proposeMessage.contents[0]);
						TheWinner <- proposeMessage.sender;
						final_msg <- proposeMessage;
					}			
			}
		}
//			if (TheWinner = )
			write "Well the winner is :" + TheWinner;
			do accept_proposal message: final_msg contents: [TheWinner];
			// Read content to remove the message from proposes variable.
			string dummy <- final_msg.contents;
//		}	
	}
	
	action CheckTheItemPrice(int ItemPrice , int NewPrice){
		if (ItemPrice < SellerMinimunItemPrice){
			ItemPrice <- SellerMinimunItemPrice;
			NewPrice <- ItemPrice;
			return NewPrice;
			write "I can not go more down";
		}	
	}
	
	
}


species Guests skills: [moving, fipa] {
	
	rgb GuestColor <- #pink;
	
	bool WantClothe <- false;
	bool WantToy <- false;
	bool WantAccessories <- false;
	
	bool WantToParticipateToDutchAuction <- false;
	
//	A list for those who want to participate to Dutch auction
	list<Guests> DutchAuctionInterestedGuests;
	
//	Guest moving target
	Seller SellerTarget;
	
	//	Create a variable to check if the agent won the auction
	bool AuctionWin <- false;
	
	bool BoughtTheItem <- false;

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
		
//		if (self.AuctionWantToParticipate = "Dutch") and (self.WantAccessories = true or self.WantClothe = true or self.WantToy = true){
//			draw "Guest : " + name + " wants to participate " + self.AuctionWantToParticipate + ". And it wants to buy " + self.ItemWantToBuy at: location + {-20, -4, -5} color: #olive font: font("Arial", 10, #bold) perspective: false;	
//		}
		
		if self.AuctionWin = true{
			GuestColor <- #olive;
		}else if self.BoughtTheItem = true{
			GuestColor <- #gold;
			draw "Guest : " + name + " I win !!! And I bought " + self.ItemWantToBuy at: location + {-20, -4, -5} color: #olive font: font("Arial", 10, #bold) perspective: false;
			draw sphere(0.9) at: (location - {0.5, 0.0, -0.8}) color:GuestColor;
		}else{
			GuestColor <- #pink;
			draw "";
		}
	}
	
	//	Moving Reflexes
	reflex MoveArround when: SellerTarget = nil{	
		do wander;
	}
	
	
	reflex MoveToSeller when: SellerTarget != nil{
		write "Ready to buy: " + ItemWantToBuy + " going to " + SellerTarget.location;
		do goto target: SellerTarget;
		if (self.location = SellerTarget.location){
			self.AuctionWin <- false;
			self.BoughtTheItem <- true;
			SellerTarget <- nil;
		}
		
	}
	//	End of Moving Reflexes
	
	reflex recieveCalls when: !empty(cfps) {
		loop cfpMessage over: cfps {
			
			write "\n\n /===========================================" + self.name + "=============================================================================/";
			write '(Time ' + time + '): ' + name + ' receives a cfp message from ' + agent(cfpMessage.sender).name + ' with content: ' + cfpMessage.contents;
			
//			["Start", SellingItem, SellerItemPrice, SellersAuction]
			if (cfpMessage.contents[0] = "Start") and (cfpMessage.contents[1] = self.ItemWantToBuy) and ( cfpMessage.contents[3] = self.AuctionWantToParticipate){
				
				GuestColor <- #olive;
				
//				Acceptance consol logs
				write "I " + self.name + " want to participate to the auction of " + cfpMessage.sender;
				write "		The proposal I receive and I accept is : " + cfpMessage.contents ;
				write "/========================================================================================================================/\n";	
				
								
				do ProposeReplyToCfpMessage(cfpMessage);
				
			}else{
				
				GuestColor <- #pink;
				do RefuseReplyToCfpMessage(cfpMessage);
				
			}
			string dummy <- cfpMessage.contents;			
		}
	}
	
	action ProposeReplyToCfpMessage(message cfpMessage){
		
		if(int(cfpMessage.contents[2]) > self.GuestAcceptedPrice){
			
			write "==================== " + self.name + " Send A new proposal to " + cfpMessage.sender +" ========================";
			write "\n I " + self.name + " can not afford these money I have only " + self.GuestAcceptedPrice + "\n But the " + cfpMessage.sender + " sells the item :" + cfpMessage.contents[2] + " euros\n";
			
//			["clothes", "accessories", "toys"]
			if (cfpMessage.contents[2] = SellersItemsAvailable[0]) {
				self.WantClothe <- true;
			}else if(cfpMessage.contents[2] = SellersItemsAvailable[1]) {
				self.WantAccessories <- true;
			}else {
				self.WantToy <- true;
			}
			
			
			
			do propose message: cfpMessage contents:[self.GuestAcceptedPrice];
			
		}
	}
	
	action RefuseReplyToCfpMessage(message cfpMessage){
		
//		Rejection consol logs
		write "I " + self.name + " don't want to participate to the auction of " + cfpMessage.sender ;
		if (cfpMessage.contents[1] != self.ItemWantToBuy){
			write "		I want: " + self.ItemWantToBuy + " but the seller sells: " + cfpMessage.contents[1];
			do refuse message: cfpMessage contents:["I don't wont to participate to your auction because I want to buy: " + self.ItemWantToBuy];	
		}else{
			write "     I want: " + self.AuctionWantToParticipate + " but the seller starts: " + cfpMessage.contents[3];	
		}
		write "/========================================================================================================================/";
		
	}
	
	
	
	
	// ------------------ START OF THE NEW PART ------------------
	reflex recieveRejectProposals when: !empty(reject_proposals) {
		GuestColor <- #pink;
		write('reject_proposals');		
		loop rejectMessage over: reject_proposals {
			
				write '(Time ' + time + '): ' + name + ' is rejected. Because has no enough money';
				write "Cry";

				
			// Read content to remove the message from reject_proposals variable.
			string dummy <- rejectMessage.contents;
		}
		
	}
	
	reflex recieveAcceptProposals when: !empty(accept_proposals) {		
		write "\n/================= The Winner of " + self.AuctionWantToParticipate + " ==================/\n";		
		loop acceptMsg over: accept_proposals {
		
			self.AuctionWin <- true;
			
			write '(Time ' + time + '): ' + acceptMsg.sender + ' declare the Winner.' + " witch is " + self.name;	
			
			write acceptMsg.contents[0,0];

//			do inform message: acceptMsg contents:["Inform from " + name];
			
			// Read content to remove the message from accept_proposals variable.
//			string dummy <- acceptMsg.contents;
			break;
		}
		
		ask Seller{
			myself.SellerTarget <- self.location;
		}
		
	}
	// ------------------ END OF THE NEW PART ------------------
	
}

experiment myExperiment type: gui{
	
	output{
		display map type: opengl{
			species Guests;
			species Seller;
		}
	}
	
}