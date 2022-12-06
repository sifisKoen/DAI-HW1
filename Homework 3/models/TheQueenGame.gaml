/**
* Name: NQueenGrid
* Based on the internal empty template. 
* Author: sonya, iosif
* Tags: 
*/


model TheQueenGame


global {
	
	int QueensNeighbors;
	int numberOfQueens <- 4;
	list<ChessBoard> OccupiedCells;
	list<Queen> positioned;
	

	init {
//		int index <- 0;
		create Queen number: numberOfQueens;
		
//		loop counter from: 1 to: numberOfQueens {
//        	Queen queen <- Queen[counter - 1];
//        	queen <- queen.setId(index);
//        	queen <- queen.initializeCell();
//        	index <- index + 1;
//        }
        
//      We define predecessors and successors of Queens
        loop counter from: 0 to: numberOfQueens - 1 {
            Queen queen <- Queen[counter];
            queen <- queen.setId(counter);
            queen <- queen.initializeCell();
            write ("Init a queen" + queen);
            if counter > 0 {
                queen.predecessor <- Queen[counter - 1];
                write ("Init a queen predecessor " + Queen[counter - 1]);
                queen.predecessor.successor <- queen;
                write ("Init a queen successor " + queen);
                
            }
            
			
        }
        Queen[0].predecessor <- Queen[numberOfQueens-1];
		Queen[0].predecessor.successor <- Queen[0];
		write "OccupiedCells " + OccupiedCells;
		add Queen[0] to: positioned;
//		do PrintSuccessorsAndPredecessors;
        ask Queen[1] {
        	do FindSafePosition;
        }
	}
}


species Queen skills: [fipa]{
    
    Queen predecessor;
    Queen successor;
	ChessBoard myCell; 
	int id; 
	int index <- 0;
	
	bool Positioned <- false;
	bool reply;
	bool helped <- false;
             
    /*
     * grid_x -> This variable stores the column index of a cell.
     * 
     * grid_y -> This variable stores the row index of a cell.
     * 
     */
//    reflex updateCell {
//  
//    	write ("\n/=============== Itteration " + self.index + " ===============/");	
//    	write ("Queen : " + self.name);
//    	write ("My neighbors Nomber is " + length(myCell.neighbors));
//    	write ("My neighbors are " + myCell.neighbors);
//    	write ("I am at cell " + myCell);
//    	loop FreeNeighbor over: myCell.neighbors{
//    		if FreeNeighbor = nil{
//    			write ("The Neighbor " + FreeNeighbor + " is free");
//    		}else {
//    			write ("The Neighbor " + FreeNeighbor + " is NOT free");
//    		}
//    	}
////    	write "I am at cell :" + myCell[myCell.grid_x, myCell.grid_y];
//    	write('id ' + id);
//    	write('X: ' + myCell.grid_x + ' - Y: ' + myCell.grid_y);
//    	myCell <- ChessBoard[myCell.grid_x,  mod(index, numberOfQueens)];
//    	location <- myCell.location;
//    	index <- index + 1;
//    }


	action PrintSuccessorsAndPredecessors {
		write ("Queen " + name + " Successor: " + self.successor + " and Predecessor: " + self.predecessor ) ;
	}
	
	action FindSafePosition{
		if ((length(OccupiedCells) >= numberOfQueens) and (length(positioned) >= numberOfQueens-1)) {
			write "EOG";
		} else {
		write ("\n/=============== " + self.name + " checking her position ===============/");	
//		Positioned <- false;
		if (CheckRow(myCell.grid_y) and CheckColumn(myCell.grid_x) and CheckDiagonal(myCell.grid_x,  myCell.grid_y)){
			Positioned <- true;
			write name + " I'm already good";
			write "Positioned " + positioned;
				if (length(positioned) < 12) {
					do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for yourself"];
		
				}
			}else{
//				int x <- self.findSafeColumn(myCell.grid_y);
//				int y <- self.findSafeRow(myCell.grid_x);
				list<ChessBoard> selfCheckList <- myCell.neighbors;
//				loop counter from: 0 to: 2 {
					add ChessBoard[myCell.grid_x, rnd(myCell.grid_y, numberOfQueens-1)] to: selfCheckList;
					add ChessBoard[rnd(myCell.grid_x, numberOfQueens-1), myCell.grid_y] to: selfCheckList;
//				}
				write "selfcheck " + selfCheckList;
				loop neighbor over: selfCheckList{
					
//				write name + " checking my neighbors";
				if (CheckRow(neighbor.grid_y) and CheckColumn(neighbor.grid_x) and CheckDiagonal(neighbor.grid_x, neighbor.grid_y)){
//				if (x != -1 and y != -1 and CheckRow(y) and CheckColumn(x) and CheckDiagonal(x,  y)){
					
					Positioned <- true;
					remove myCell from: OccupiedCells;
					myCell <- neighbor;
					
//					myCell <- ChessBoard[x, y];
					add myCell to: OccupiedCells;
					location <- myCell.location;
					write name + " I moved to my neighborhood " + myCell;
					write "Occupied cells" + OccupiedCells;
					if !(positioned contains self) {
						add self to: positioned;
					}
					write "Positioned" + positioned;
					do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for yourself"];
					break;

					}
			}
			if (!Positioned) {
				write name + " Asking my predecessor to find a position";
				do start_conversation to: list(predecessor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for me", name];
			}
		}
	}
	
	}
	
	
	reflex FindPositionMessage when: !empty(cfps){
		write "Occupied cells: " + OccupiedCells;
		write "Positioned " + positioned;
		if ((length(OccupiedCells) >= numberOfQueens-1) and (length(positioned) >= numberOfQueens)) {
			write "EOG";
		} else {
		
		loop msg over: cfps{
			
			if(msg.contents[0] = "Null reply"){
				reply <- false;
			} else if (msg.contents[0] = "Find position for yourself"){
				if (Positioned) {
					write name + " I'm already good";
					if (length(positioned) < numberOfQueens) {
						do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for yourself"];
					}
				} else {
					do FindSafePosition;
				}
			} else if (msg.contents[0] = "I insist"){
				write "Positioned " + positioned;
				
				if (length(positioned) < numberOfQueens) {
					if (Positioned) {
						Positioned <- false;
						remove myCell from: OccupiedCells;
						remove self from: positioned;
						myCell <- ChessBoard[0, 2];
						location <- myCell.location;
						add myCell to: OccupiedCells;
					}
					do FindSafePosition;
//					do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for yourself"];
				}
				
				
			} else if (msg.contents[0] = "Find position for me"){
				write name + " was asked to find a position.";
				reply <- true;
				helped <- false;
				list<ChessBoard> selfCheckList <- myCell.neighbors;
				loop counter from: 0 to: 2 {
					add ChessBoard[rnd(numberOfQueens - 1), rnd(numberOfQueens - 1)] to: selfCheckList;
				}
				write "selfcheck " + selfCheckList;
				loop neighbor over: selfCheckList {
				
					if (CheckRow(neighbor.grid_y) and CheckColumn(neighbor.grid_x) and CheckDiagonal(neighbor.grid_x,  neighbor.grid_y)){
						if (msg.contents[1] != name){
							write name + " Found a neighbor place for my successor " + successor + " location: "+ neighbor;
							do propose message: msg contents: [neighbor];
							helped <- true;
							reply <- false;
							break;
					} else {
						write name + " Found a place for myself " + successor + " location: "+ neighbor;
							Positioned <- true;
							remove myCell from: OccupiedCells;
							myCell <- neighbor;
							location <- myCell.location;
							add myCell to: OccupiedCells;
							write "Occupied cells: " + OccupiedCells;
							if !(positioned contains self) {
								add self to: positioned;
							}
							write "Positioned " + positioned;
							helped <- true;
							reply <- false;
							do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for yourself"];
							break;
					}
					
					}
				}
//				write name + " helped? " + helped;
				if (!helped) {
					if (msg.contents[1] != name){
						do start_conversation to: list(predecessor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for me", msg.contents[1]];
					} else{
						write name + " couldn't find a place, skip my turn";
						do start_conversation to: list(Queen) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Null reply"];
						do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["I insist"];
					}
					helped <- false;
				}
			} else if (msg.contents[0] = "Found position for you"){
				if (!reply) {
						Positioned <- true;
						remove myCell from: OccupiedCells;
						myCell <- msg.contents[1];
						location <- myCell.location;
						add myCell to: OccupiedCells;
						write "Occupied cells: " + OccupiedCells;
						if !(positioned contains self) {
							add self to: positioned;
						}
						write positioned;
						write name + " positioned by a cfp";
						helped <- false;
						do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for yourself"];
		
					} else {
						do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Found position for you", msg.contents[1]];
						write name + " sent a position " + msg.contents[1];
						helped <- false;
						reply <- false;
					}
			}
			
		}
	}	
	}
	
	reflex AcceptPositionMessage when: !empty(proposes){
		message position <-proposes at 0;
		if (reply) {
			write name + " Forward message to " + successor;
			helped <- false;
			do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Found position for you", position.contents[0]];
			reply <- false;
		} else {
		
			Positioned <- true;
			remove myCell from: OccupiedCells;
			myCell <- position.contents[0];
			add myCell to: OccupiedCells;
			location <- myCell.location;
			if !(positioned contains self) {
						add self to: positioned;
					}
			write positioned;
			write name + " positioned by a propose";
			do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for yourself"];
		
		}
	}
	
	
//	int findSafeColumn(int RowNumber){
//		write name + " Finding column for a row " + RowNumber;
//		
//		loop counter from: 0 to: numberOfQueens - 1 {
//			if (!(OccupiedCells contains ChessBoard[counter, RowNumber]) and CheckRow(counter)){
//				write "Found this cell " + ChessBoard[counter, RowNumber];
//				write "counter column: " + counter;
//				return counter;
//			}
//			write "Checked this cell " + ChessBoard[counter, RowNumber];
//		}
//		return -1;
//	}
	
	bool CheckRow(int RowNumber){
		write name + " Checking row " + RowNumber;
		
		loop counter from: 0 to: numberOfQueens - 1 {
			if(OccupiedCells contains ChessBoard[counter, RowNumber] ){
				write ChessBoard[counter, RowNumber].name + " does not fit in row";
				return false;
			}
		}
		return true;
	}
	
	bool CheckColumn(int ColumnNumber){
		write name + " Checking column " + ColumnNumber;
		
		loop counter from: 0 to: numberOfQueens - 1 {
			if(OccupiedCells contains ChessBoard[ColumnNumber, counter] ){
				write ChessBoard[ColumnNumber, counter].name + " does not fit in column";
				return false;
			}
			
		}
		return true;
	}
	
//	int findSafeRow(int ColumnNumber){
//		write name + " Finding row for a column" + ColumnNumber;
//		
//		loop counter from: 0 to: numberOfQueens - 1 {
//			if (!(OccupiedCells contains ChessBoard[ColumnNumber, counter]) and CheckColumn(counter)){
//				write "Found this cell " + ChessBoard[ColumnNumber, counter];
//				write "counter row: " + counter;
//				return counter;
//			}
//			write "Checked this cell " + ChessBoard[ColumnNumber, counter];
//		}
//		return -1;
//	}
	
	bool CheckDiagonal(int ColumnNumber, int RowNumber){
		write name + " Checking diagonals";
		int Column <- ColumnNumber - 1;
		int Row <- RowNumber -1;
		
		write "D Init " + ColumnNumber + " " + RowNumber;
		loop while: (Column >= 0 and Row >= 0){
			if(OccupiedCells contains ChessBoard[Column, Row]){
				write ChessBoard[Column, Row].name + " does not fit in d1";
				return false;
			}
//			write name + "Checked d " + ChessBoard[Column, Row];
			Column <- Column - 1;
			Row <- Row  - 1;
		}
		
		Column <- ColumnNumber + 1;
		Row <- RowNumber - 1;
		
		loop while: (Row < numberOfQueens and Row >= 0 and Column >= 0){
			if (OccupiedCells contains ChessBoard[Column, Row]){
				write ChessBoard[Column, Row].name + " does not fit in d2";
				return false;
			}
//			write name + "Checked d " + ChessBoard[Column, Row];
			Row <- Row + 1;
			Column <- Column - 1;
		}
		
		Column <- ColumnNumber + 1;
		Row <- RowNumber + 1;
		
		loop while: (Row < numberOfQueens and Row >= 0 and Column < numberOfQueens and Column >= 0){
			if (OccupiedCells contains ChessBoard[Column, Row]){
				write ChessBoard[Column, Row].name + " does not fit in d2";
				return false;
			}
//			write name + "Checked d " + ChessBoard[Column, Row];
			Row <- Row + 1;
			Column <- Column + 1;
		}
		
		Column <- ColumnNumber - 1;
		Row <- RowNumber + 1;
		
		loop while: (Row >= 0 and Column < numberOfQueens and Column >= 0){
			if (OccupiedCells contains ChessBoard[Column, Row]){
				write ChessBoard[Column, Row].name + " does not fit in d2";
				return false;
			}
//			write name + "Checked d " + ChessBoard[Column, Row];
			Row <- Row - 1;
			Column <- Column + 1;
		}
		
		return true;
	}
	
	
	/*
	 * Initializations
	 */
	Queen setId(int input) {
        id <- input;
        return self;
    }

    Queen initializeCell {
        myCell <- ChessBoard[0, 0];
        write "Added " + name + " to cell " + myCell;
        add myCell to: OccupiedCells;
        return self;
    }
	
//	Visual acpect
	float size <- 30/numberOfQueens;
	
	aspect base {
        draw circle(size) color: #blue ;
        draw "Id: " + string(id) at: myCell.location color: #olive font: font("Arial", 10, #bold) perspective: false;
       	draw myCell.name at: myCell.location - {4.0, -1.5, -1.5} color: #olive font: font("Arial", 10, #bold) perspective: false;
//       	 write "Locating " + name + " to cell " + myCell;
       	location <- myCell.location;
    }

}
    

/*
 * We make our grid QueenNumber x QueenNumber 
 * So our queens be exactely as the cells of our grid
 * 
 * The neighbors is a build in variable witch returns the list
 * of cells at a distance of 1.
 * 
 */    
grid ChessBoard width: numberOfQueens height: numberOfQueens neighbors: QueensNeighbors{ 
	init{
		if(even(grid_x) and even(grid_y)){
			color <- #black;
		}
		else if (!even(grid_x) and !even(grid_y)){
			color <- #black;
		}
		else {
			color <- #white;
			draw name at: location color: #olive font: font("Arial", 10, #bold) perspective: false;			
		}
		
	}
}

experiment NQueensProblem type: gui{
	output{
		display ChessBoard{
			grid ChessBoard border: #black ;
			species Queen aspect: base;
		}
	}
}
