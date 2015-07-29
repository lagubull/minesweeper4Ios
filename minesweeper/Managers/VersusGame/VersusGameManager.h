//
//  VersusGameManager.h
//  minesweeper
//
//  Created by jlagunas on 12/04/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VersusViewController.h"
#import "VersusGame.h"

#define PLAYER_1 1
#define PLAYER_2 2

@interface VersusGameManager : NSObject <UIAlertViewDelegate>


@property (nonatomic) VersusGame *vGame;


@property (nonatomic, strong) VersusViewController *vvc;


-(void) cellSelected: (int) cellID;
-(void) initGame;

@end
