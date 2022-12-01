/**
* Name: NQueenGrid
* Based on the internal empty template. 
* Author: shirint
* Tags: 
*/


model TheQueenGame


global {
	
	int QueensNeighbors;
	int numberOfQueens <- 12;
	list<ChessBoard> OccupiedCells;
	

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
        Queen[0].predecessor <- Queen[11];
		Queen[0].predecessor.successor <- Queen[0];
		write OccupiedCells;
//		do PrintSuccessorsAndPredecessors;
        ask Queen[0] {
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
		if (CheckRow(myCell.grid_y) and CheckColumn(myCell.grid_x) and CheckDiagonal(myCell.grid_y,  myCell.grid_x)){
			Positioned <- true;
			write "I'm already good";
			do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for yourself"];
		}else{
			loop neighbor over: myCell.neighbors{	
				
				if (CheckRow(neighbor.grid_y) and CheckColumn(neighbor.grid_x) and CheckDiagonal(neighbor.grid_y,  neighbor.grid_x)){
					write "I moved to my neighbor";
					Positioned <- true;
					remove myCell from: OccupiedCells;
					myCell <- neighbor;
					add neighbor to: OccupiedCells;
					location <- myCell.location;
					write OccupiedCells;
					do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for yourself"];
					break;

					}
			}
			if (!Positioned) {
				write "Asking my predecessor to find a position";
				do start_conversation to: list(predecessor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for me"];
			}
		}
	}
	
	
	reflex FindPositionMessage when: !empty(cfps){
		
		
		loop msg over: cfps{
			
			if (msg.contents[0] = "Find position for yourself"){
				if (!Positioned) {
					do FindSafePosition;
				
				} else {
					write "I'm good";
				}
				
			} else if (msg.contents[0] = "Find position for me"){
				
				loop neighbor over: myCell.neighbors{	
				
					if (CheckRow(neighbor.grid_y) and CheckColumn(neighbor.grid_x) and CheckDiagonal(neighbor.grid_y,  neighbor.grid_x)){
						write "Found a neighbor for my successor";
						do propose message: msg contents: [neighbor];
						helped <- true;
						break;
				
					}
				}
				if (!helped) {
					reply <- true;
					do start_conversation to: list(predecessor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for me"];
				}
			} else if (msg.contents[0] = "Found position for you"){
				if (!reply) {
						Positioned <- true;
						myCell <- msg.contents[1];
						location <- myCell.location;
						do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for yourself"];
		
					} else {
						do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Found position for you", msg.contents[1]];
						write "sent a position";
						helped <- true;
						reply <- false;
					}
			}
			
		}
		
	}
	
	reflex AcceptPositionMessage when: !empty(proposes){
		message position <-proposes at 0;
		if (!reply) {
			do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Found position for you", position.contents[0]];
			reply <- false;
		} else {
		
		Positioned <- true;
		myCell <- position.contents[0];
		location <- myCell.location;
		do start_conversation to: list(successor) protocol: 'fipa-contract-net' performative: 'cfp' contents: ["Find position for yourself"];
		
		}
	}
	
	
	
	bool CheckRow(int RowNumber){
		
		loop counter from: 0 to: numberOfQueens - 1 {
			if(OccupiedCells contains ChessBoard[counter, RowNumber] ){
				return false;
			}
			return true;
		}
	}
	
	bool CheckColumn(int ColumnNumber){
		
		loop counter from: 0 to: numberOfQueens - 1 {
			if(OccupiedCells contains ChessBoard[ColumnNumber, counter] ){
				return false;
			}
			return true;
		}
	}
	
	bool CheckDiagonal(int RowNumber, int ColumnNumber){
		int Column <- ColumnNumber - 1;
		int Row <- RowNumber -1;
		
		loop while: (Column >= 0 and Row >= 0){
			if(OccupiedCells contains ChessBoard[Column, Row]){
				return false;
			}
			Column <- Column - 1;
			Row <- Row  - 1;
		}
		
		Column <- ColumnNumber + 1;
		Row <- RowNumber - 1;
		
		loop while: (Row < numberOfQueens and Row >= 0 and Column >= 0){
			if (OccupiedCells contains ChessBoard[Column, Row]){
				return false;
			}
			Row <- Row + 1;
			Column <- Column - 1;
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
        myCell <- ChessBoard[id, id];
        
        add myCell to: OccupiedCells;
        return self;
    }
	
//	Visual acpect
	float size <- 30/numberOfQueens;
	
	aspect base {
        draw circle(size) color: #blue ;
       	location <- myCell.location ;
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