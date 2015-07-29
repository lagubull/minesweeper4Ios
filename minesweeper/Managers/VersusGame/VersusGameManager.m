//
//  GameManager.m
//  minesweeper
//
//  Created by jlagunas on 12/04/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "VersusGameManager.h"
#import "Tools.h"
#import "DBManager.h" 

@implementation VersusGameManager

int versusGameStatus = 0;

@synthesize vvc;

@synthesize vGame;

-(id) init
{
    vGame = [[VersusGame alloc] initWithNumMines:60 numColumns:14 numRows:15];
 
  
    
    return self;
}

-(void) initGame
{
    [vvc loadBoard];
    if (vGame.game_internal_id == -1)
    {
        //initialise the board
        vGame.player = PLAYER_1;
        
        [vGame initGame];
    }
    else
    {
       
       [self restoreGameController];
    }
    [vvc passTurn: vGame.player];
    /*For test purposes*/
  /*  for (int i = 0; i < _num_rows; i++)
        for (int j = 0; j < _num_columns; j++)
            [bvc paintCell: i*10+j +CONSTANT  title : [NSString stringWithFormat: @"%d",board[i][j] ] ];*/
}

-(void) clickCell: (int) r column: (int) c
{
    //if cell had not been clicked before
    if (vGame.visible[r][c]==0)
    {
       
        if (vGame.board[r][c] != 9)
        {
            //reveal cell's content
            vGame.visible[r][c]=vGame.player;
            NSString *value;
            value  = [NSString stringWithFormat: @"%d",vGame.board[r][c]] ;
                       [vvc paintCell: (r * CONSTANT_ROW + c + CONSTANT_ROW) title :value];
            //if not near mines
            if (vGame.board[r][c]==0)
            {
                //loop through the nearby cells and click them aswell
                for (int r2= MAX(0,r-1);r2 < MIN(vGame.num_rows, r+2);r2++)
                {
                    for (int c2= MAX(0,c-1);c2 < MIN(vGame.num_columns,c+2);c2++)
                    {
                        [self clickCell: r2 column: c2];
                    }
                }
            }
            
        }
    }
}

-(void) passTurn: (int) cellId
{
    switch (vGame.player)
    {
        case PLAYER_1:  vGame.player = PLAYER_2;
                        self.vGame.last_cell_player1 = cellId;
                        break;
        case PLAYER_2:  vGame.player = PLAYER_1;
                        self.vGame.last_cell_player2 = cellId;
                        break;
    }
    [vvc passTurn: vGame.player];
}

-(void) updateMinesCount
{
    vGame.remainingMines--;
    switch (vGame.player)
    {
        case PLAYER_1:  vGame.mines_player1++;
                        break;
        case PLAYER_2:  vGame.mines_player2++;
                        break;
    }
    [vvc updateMinesCounters];
}

-(void) checkVictory
{
    [self updateMinesCount];
    
    if (vGame.mines_player1  >= vGame.num_mines/2)
    {
        //Player 1 Victory

        [Tools showSingleButtonAlert:NSLocalizedString(@"WINNER",@"Winner title") message:NSLocalizedString(@"YOU_WIN",@"Winner message") buttonText:NSLocalizedString(@"PLAY_AGAIN",@"Play again button") delegate:self];
    }
    else
    {
        if (vGame.mines_player2  >= vGame.num_mines/2)
        {
            //Player 2 Victory
            [Tools showSingleButtonAlert:NSLocalizedString(@"WINNER",@"Winner title") message:NSLocalizedString(@"YOU_WIN",@"Winner message") buttonText:NSLocalizedString(@"PLAY_AGAIN",@"Play again button") delegate:self];
        }
        
    }
}

-(void) cellSelected: (int) cellID
{
    if (vGame.last_cell_player1 == -1)
        [vGame persist];
    
        int *r;
        int *c;
        r = malloc(4);
        c = malloc(4);
        [vGame findCoordinates: cellID  row: r column: c];
        
        if (vGame.visible[*r][*c] == 0)
        {
            if (vGame.board[*r][*c] == 9)
            {
                    vGame.visible[*r][*c]=vGame.player;
                [vvc paintMine:(*r*CONSTANT_ROW + *c + CONSTANT_ROW) player: vGame.player animation:YES ];
                    //mine
                    [self checkVictory];
            }
            else
            {
                //empty cell
                [self clickCell: *r column: *c ];
                [self passTurn: vGame.player];
            }
            [vGame update];
        }

   }


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self initGame];
}

-(void) restoreGameController
{
    for (int r = 0;r < vGame.num_rows;r++)
    {
        for (int c = 0;c < vGame.num_columns;c++)
        {
            if (vGame.visible[r][c] != 0)
            {
                if (vGame.board[r][c] != 9)
                {
                    NSString *value;
                    value  = [NSString stringWithFormat: @"%d",vGame.board[r][c]] ;
                    [vvc paintCell: (r * CONSTANT_ROW + c + CONSTANT_ROW) title :value];
                }
                else
                {
                    [vvc paintMine:(r*CONSTANT_ROW + c + CONSTANT_ROW) player: vGame.visible[r][c] animation:NO];
                }
            }
       }
    }
}

@end
