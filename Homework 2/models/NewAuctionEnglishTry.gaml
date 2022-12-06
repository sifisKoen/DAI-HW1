/**
* Name: FipaContractNetProtocol
* Based on the internal empty template. 
* Author: shirint
* Tags: 
*/


model NewAuctionEnglishTry

global {
	
	int GuestsNumber <- 15;
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
	
	message MessageWithCurrentHighestPrice;
	
	
	/*
	 * reflex for start the English Auction
	 * In this reflex we are sending some informations for Guests/Bidders
	 * So to decide if it wants to participate to this auction.
	 * ["Start", SellingItem, SellerItemPrice, SellersAuction]
	 */	
	reflex sendProposalToAllBidders when: (time = 1) {
		
		SellingItem <- SellersItemsAvailable[rnd(length(SellersItemsAvailable) - 1)];
		SellerItemPrice <- rnd(SellerMinimunItemPrice, SellerMaximumItemPrice);
		
		write "\n\n\n/========================================================================================================================/";
		write  "Start of the auction: I " + self.name + " started an auction type of: " +  self.SellersAuction + ", my Item for selling is: " + SellingItem + " and the price is: " + SellerItemPrice + "€\n"; 
		write '(Time ' + time + '): ' + name + ' sent a public message to all bidders.';
		
		if (SellersAuction = "English") {
			do start_conversation to: list(Guests) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Start", SellingItem, SellerMinimunItemPrice, SellersAuction];	
		}		
	}
	
	reflex receive_refuse_messages when: !empty(refuses) {
		
		write("\n=============== Refuses ===========================");
				
		loop refuseMsg over: refuses {
			write ("\n(Time " + time + "): " + agent(refuseMsg.sender).name + " refused.");
			write ("The agent " + agent(refuseMsg.sender).name + " refused because it says: ( " + refuseMsg.contents[0] + " )");
			
			
			// Read content to remove the message from refuses variable.
			string dummy <- refuseMsg.contents[0];
		}
	}
	
	
	/*
	 * In this reflex Seller receive proposals from the Guests
	 */
	reflex recieveProposals when: !empty(proposes) {
		
		list<message> AcceptMessagesList <- proposes; 
		list<message> Proposes <- proposes; 
		
		write ("\n=============== "+ self.name + " Receive Proposals =========================\n");
		
		/*
		 * We use if because we are in English auction
		 * and in English auction in the end will be only one Guest stand
		 * so this Guest is the winner
		 */
		if (length(proposes) != 1) {
			/*
		 	* In this loop we can take the Guest with the highest Bid
		 	* 
		 	*/
			loop ProposeHighestMessage over: AcceptMessagesList{
			
				if (self.NewItemPrice < int(ProposeHighestMessage.contents[0])) {
				
					self.NewItemPrice <- int(ProposeHighestMessage.contents[0]);
				
					MessageWithCurrentHighestPrice <- ProposeHighestMessage; 

				}
			
			}
		
		
			/*
		 	* In this loop we send the messagies to all the biders who will continue
		 	* to the auction
		 	*/
			loop proposeMessage over: Proposes {
				
				
				if (self.NewItemPrice > int(proposeMessage.contents[0])) {
					
					do reject_proposal message: proposeMessage  contents: ["Sorry " + proposeMessage.sender +" you can not continue to this auction you don't have sufficient money.\nYou send me: " + proposeMessage.contents[0] + " but currently I have: " + self.NewItemPrice ];
					
				}
			
				write ("\n================ Guest " + proposeMessage.sender + " =================================");
				write ("I " + self.name + " have taken proposal from " + proposeMessage.sender + " with " + proposeMessage.contents[0]) + "\n";
				write ("I am ready to send a propose message to " + proposeMessage.sender);
//				do propose message: proposeMessage contents: [self.NewItemPrice];
//				do start_conversation to: proposeMessage.sender protocol: 'no-protocol' performative: 'inform' contents: [self.NewItemPrice] ;
				do inform message: proposeMessage contents: [self.NewItemPrice];
			}
			write ("\n/================= Highest Bid ================================/");
			write ("\nThe " + MessageWithCurrentHighestPrice.sender + " For now has the highest bid with " + self.NewItemPrice);
			write ("\n/==============================================================/\n");
		} else {
			
			loop Winner over: proposes {
				
				do accept_proposal message: Winner contents: ["Winner"];
				
			}
			
		}
		
	}
		
		
		
}


species Guests skills: [fipa, moving] {
	
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

//	Create a variable to check if the agent bought the item from the Seller
	bool BoughtTheItem <- false;

//	Selection of a new random item
	string ItemWantToBuy <- SellersItemsAvailable[rnd(length(SellersItemsAvailable) - 1)];
	
//	Whitch is the type of auction the Guest wants to participate
	string AuctionWantToParticipate <- TypeOfAuction[rnd(length(TypeOfAuction) - 1)];
	
//	Create a random accepted price for each Guest so to take place to the auction
	int  GuestAcceptedPrice <- rnd(GuestMinimumAcceptancePrice, GuestMaximumAcceptancePrice);
	
//	Create a variable so our Bider wil be able to make New Propose to the Seller/Auctioneer
	int NewProposedPrice <- rnd(GuestMinimumAcceptancePrice, self.GuestAcceptedPrice);
	
	
	reflex recieveCalls when: !empty(cfps) {
		loop cfpMessage over: cfps {
			
			write "\n\n /===========================================" + self.name + "=============================================================================/";
			write '(Time ' + time + '): ' + self.name + ' receives a cfp message from ' + agent(cfpMessage.sender).name + ' with content: ' + cfpMessage.contents;
			
//			["Start", SellingItem, SellerItemPrice, SellersAuction]			
			if (cfpMessage.contents[0] = "Start") and (cfpMessage.contents[1] = self.ItemWantToBuy) and ( cfpMessage.contents[3] = self.AuctionWantToParticipate){
				
				GuestColor <- #olive;
				
//				Acceptance consol logs
				write "I " + self.name + " want to participate to the auction of " + cfpMessage.sender;
				write "		The proposal I receive and I accept is : " + cfpMessage.contents ;
				write "/========================================================================================================================/\n";	
			
				do ProposeReplyToCfpMessage(cfpMessage);
				
			}else {
				
				GuestColor <- #pink;
				do RefuseReplyToCfpMessage(cfpMessage);
				
			}
			string dummy <- cfpMessage.contents;			
		}
	}
	
	
	
	
	reflex recieveInforms when: !empty(informs){
		write ("/================ Guest " + self.name +" Receive Informs for the Auction ==========================/");
		loop informMsg over: informs {
			write ("(Time " + time + "): " + name + " received a confirm message from " + agent(informMsg.sender).name + " with content: " + informMsg.contents);
			
			NewProposedPrice <- NewProposedPrice + rnd(1, 3); 
			
			int NewMoney <- CheckGuestMoney (NewProposedPrice, GuestAcceptedPrice);
			
			do propose message: informMsg contents: [NewMoney];
		}
		write ("==============================================================================");
	}
	
	

	
	
	// ------------------ START OF THE NEW PART ------------------
	reflex recieveRejectProposals when: !empty(reject_proposals) {
		write("\n==================== " + self.name +" Reject_proposals ==============");		
		loop rejectMsg over: reject_proposals {
			
			write ("(Time " + time + "): " + name + " is rejected.");
			write ("The " + rejectMsg.sender + " removes me from the auction because: " + rejectMsg.contents[0]);
			// Read content to remove the message from reject_proposals variable.
			string dummy <- rejectMsg.contents[0];
		}
	}
	
	
	reflex recieveAcceptProposals when: !empty(accept_proposals) {		
		write("\n========================"+ self.name +" Accept Proposal=============================");
			
		loop acceptMessage over: accept_proposals {
			
			write ("(Time " + time + "): " + name + " is accepted.");
			write ("I have " + self.GuestAcceptedPrice);
			write ("I am the winner !! : " + acceptMessage.sender + " says: " + acceptMessage.contents[0]);
			
				
			// Read content to remove the message from accept_proposals variable.
			string dummy <- acceptMessage.contents[0];
		}
	}
	// ------------------ END OF THE NEW PART ------------------
	
	
	
	
	
	
//	-------------------- Action Section Start ---------------------
	
	int CheckGuestMoney(int ProposedMoney, int GuestPocketMoney){
		
		if (ProposedMoney > GuestPocketMoney){
			
			ProposedMoney <- GuestPocketMoney;
			 
			write ("I can not go more up ");
			return ProposedMoney;
			
		} else {
			
			return ProposedMoney;
			
		}
		
		
	}
	
	/*
	 * In this section we develloped the Guest/Bidder actions
	 * 
	 * ProposeReplyToCfpMessage
	 * 		 
	 * 
	 */
	action ProposeReplyToCfpMessage(message cfpMessage){
		
		if(int(cfpMessage.contents[2]) < self.GuestAcceptedPrice){
			
			write "==================== " + self.name + " Send A new proposal to " + cfpMessage.sender +" ========================";
			write "\n I " + self.name + " have " + self.GuestAcceptedPrice + " so I can afford to participate to " + cfpMessage.sender + " auction ";
			
//			["clothes", "accessories", "toys"]
			if (cfpMessage.contents[1] = SellersItemsAvailable[0]) {
				self.WantClothe <- true;
			}else if(cfpMessage.contents[1] = SellersItemsAvailable[1]) {
				self.WantAccessories <- true;
			}else {
				self.WantToy <- true;
			}
				
			do propose message: cfpMessage contents:[NewProposedPrice];
			
		} else if (int(cfpMessage.contents[2]) > self.GuestAcceptedPrice){
			
			do refuse message: cfpMessage contents:["I can not afford to be part of this auction. I have only: " + self.GuestAcceptedPrice];
			
		}
	}
	
	
	/*
	 * Here the guest rend a refuse message to Auctioneer/Seller
	 * Its refure its propably becuase it want an other auction OR an other item.
	 */	
	action RefuseReplyToCfpMessage(message cfpMessage){
		
//		Rejection consol logs
		write "\nI " + self.name + " don't want to participate to the auction of " + cfpMessage.sender ;
		if (cfpMessage.contents[1] != self.ItemWantToBuy){
			write "		I want: " + self.ItemWantToBuy + " but the seller sells: " + cfpMessage.contents[1];
			do refuse message: cfpMessage contents:["I don't wont to participate to your auction because I want to buy: " + self.ItemWantToBuy];	
		} else{
			write "     I want: " + self.AuctionWantToParticipate + " but the seller starts: " + cfpMessage.contents[3];	
		}
		write "/========================================================================================================================/\n";
		
	}
	
//	-------------------- Action Section End ---------------------	
	
}

experiment myExperiment {}