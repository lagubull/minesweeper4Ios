//
//  VersusGameCell.m
//  minesweeper
//
//  Created by jlagunas on 13/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "VersusGameCell.h"
#import "VersusGame.h"
#import "JCTTools.h"

@implementation VersusGameCell

- (void)setVersusGames:(VersusGame *)vGame
{
    [JCTTools versionedScaleFactor:self.lblRemainingMines
                            factor:0.7
                              size:15];
    
    [JCTTools versionedTextAlignment:self.lblRemainingMines
                           alignment:NSTextAlignmentLeft];
    
    /*---------------*/
    
    [self.lblPlayer1 setText:[NSString stringWithUTF8String:[vGame.player1Username UTF8String]]];
    
    
    [JCTTools versionedScaleFactor:self.lblPlayer1
                            factor:0.7
                              size:15];
    
    [JCTTools versionedTextAlignment:self.lblPlayer1
                           alignment:NSTextAlignmentLeft];
    
    /*---------------*/
    
    [self.lblPlayer2 setText: [NSString stringWithUTF8String: [vGame.player2Username UTF8String]]];
    [JCTTools versionedScaleFactor:self.lblPlayer2
                            factor:0.7
                              size:15];
    [JCTTools versionedTextAlignment:self.lblPlayer2 alignment:NSTextAlignmentLeft];
    
    /*---------------*/
    
    [self.lblPlayer1Mines setText: [NSString stringWithFormat:@"%@", @([vGame minesPlayer1])]];
    [JCTTools versionedScaleFactor:self.lblPlayer1Mines
                            factor:0.7
                              size:15];
    [JCTTools versionedTextAlignment:self.lblPlayer1Mines alignment:NSTextAlignmentCenter];
    
    /*---------------*/
    
    [self.lblPlayer2Mines setText:[NSString stringWithFormat:@"%@", @([vGame minesPlayer2])]];
    
    [JCTTools versionedScaleFactor:self.lblPlayer2Mines
                            factor:0.7
                              size:15];
    
    [JCTTools versionedTextAlignment:self.lblPlayer2Mines alignment:NSTextAlignmentCenter];
    
    /*---------------*/
    
    [self.lblMines setText: [NSString stringWithFormat:@"%@", @([vGame remainingMines])]];
    
    [JCTTools versionedScaleFactor:self.lblMines
                            factor:0.7
                              size:15];
    [JCTTools versionedTextAlignment:self.lblMines alignment:NSTextAlignmentCenter];
    
    [self.lblDate setText:[NSString stringWithUTF8String:[vGame.dateLastPlayed UTF8String]]];
    
    [JCTTools versionedScaleFactor:self.lblDate
                            factor:0.7
                              size:15];
    
    [JCTTools versionedTextAlignment:self.lblDate alignment:NSTextAlignmentLeft];
}

@end
