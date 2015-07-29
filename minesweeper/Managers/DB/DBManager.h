//
//  DBManager.h
//  DBTest
//
//  Created by admin on 24/04/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import <Foundation/Foundation.h>
#define RESTORABLE_GAMES 10

@class VersusGame;
@class SingleGame;

@interface DBManager : NSObject

-(void) createsDB;
-(void) upgrade: (int) oldVersion newVersion:(int) newVersion;
-(void) createVersusGame: (VersusGame *) versusGame;
-(NSMutableArray *) getRestorableVersusGame;
-(int)  getLatestVersusGame;
- (void) updateVersusGame: (VersusGame *) game;

@end
