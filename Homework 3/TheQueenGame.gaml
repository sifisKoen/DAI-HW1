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

	init {
		int index <- 0;
		create Queen number: numberOfQueens;
		
		loop counter from: 1 to: numberOfQueens {
        	Queen queen <- Queen[counter - 1];
        	queen <- queen.setId(index);
        	queen <- queen.initializeCell();
        	index <- index + 1;
        }
	}
}


species Queen skills: [fipa]{
    
	ChessBoard myCell; 
	int id; 
	int index <- 0;
             
    /*
     * grid_x -> This variable stores the column index of a cell.
     * 
     * grid_y -> This variable stores the row index of a cell.
     * 
     */
    reflex updateCell {
  
    	write ("\n/=============== Itteration " + self.index + " ===============/");	
    	write ("Queen : " + self.name);
    	write ("My neighbors Nomber is " + length(myCell.neighbors));
    	write ("My neighbors are " + myCell.neighbors);
    	write ("I am at cell " + myCell);
    	loop FreeNeighbor over: myCell.neighbors{
    		if FreeNeighbor = nil{
    			write ("The Neighbor " + FreeNeighbor + " is free");
    		}else {
    			write ("The Neighbor " + FreeNeighbor + " is NOT free");
    		}
    	}
//    	write "I am at cell :" + myCell[myCell.grid_x, myCell.grid_y];
    	write('id ' + id);
    	write('X: ' + myCell.grid_x + ' - Y: ' + myCell.grid_y);
    	myCell <- ChessBoard[myCell.grid_x,  mod(index, numberOfQueens)];
    	location <- myCell.location;
    	index <- index + 1;
    }


	/*
	 * Initializations
	 */
	action setId(int input) {
		id <- input;
	}
	
	action initializeCell {
		myCell <- ChessBoard[id, id];
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