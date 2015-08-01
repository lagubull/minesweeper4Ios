//
//  VersusViewController.m
//
//  Created by jlagunas on 30/04/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "VersusViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "Tools.h"
#import "VersusGameManager.h"
#import "MATCGlossyButton.h"
#import "VersusGame.h"

@interface VersusViewController ()

@end

@implementation VersusViewController

VersusGameManager *vgm;
float cell_width;
float cell_height;
UIView * disclaimerView;
UITextView * bodyTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    vgm = [[VersusGameManager alloc] init];
    [vgm setVersusViewController: self];
    if (self.vGame != nil)
        [vgm setVersusGame: self.vGame];
    [super viewDidLoad];
    
    cell_height = cell_width = _boardScroll.frame.size.width / [vgm.versusGame columnsNumber];
    cell_height = cell_width = MIN(2 *(_boardScroll.frame.size.width / [vgm.versusGame columnsNumber]), cell_width);
    cell_height = cell_width = MAX((_boardScroll.frame.size.width / [vgm.versusGame columnsNumber]), cell_width);
    cell_height = MAX((_boardScroll.frame.size.height / [vgm.versusGame rowsNumber]), cell_height);

    [vgm setupGame];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
    [self.view addGestureRecognizer:pinchGesture];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self initLabels];
    
}

-(void) initLabels
{
    [_lblRemainingMines setText:
     NSLocalizedString(@"MINES_LEFT",@"Remaining mines")];
    [Tools versionedScaleFactor:_lblRemainingMines factor:0.7 size:15];
    [Tools versionedTextAlignment:_lblRemainingMines alignment:NSTextAlignmentCenter];
    
    [_lblPlayer1 setText: [NSString stringWithUTF8String: [[NSString stringWithFormat: @" %@:",
     NSLocalizedString(@"PLAYER_1",@"Player 1 text")] UTF8String ]] ];
    [Tools versionedScaleFactor:_lblPlayer1 factor:0.7 size:15];
    [Tools versionedTextAlignment:_lblPlayer1 alignment:NSTextAlignmentLeft];
    
    [_lblPlayer2 setText: [NSString stringWithUTF8String: [[NSString stringWithFormat: @" %@:",
     NSLocalizedString(@"PLAYER_2",@"Player 2 text")] UTF8String ]] ];
    [Tools versionedScaleFactor:_lblPlayer2 factor:0.7 size:15];
    [Tools versionedTextAlignment:_lblPlayer2 alignment:NSTextAlignmentLeft];
}

- (IBAction)selection:(id)sender
{
    [vgm cellSelected:((UIButton *)sender).tag];
}

-(void) reloadBoard
{
    [_boardScroll setContentSize: CGSizeMake([vgm.versusGame columnsNumber] * cell_width, [vgm.versusGame rowsNumber] * cell_height)];
    
    [self resizeSubViews: [_boardScroll subviews]];
    for (int r = 0;r < [vgm.versusGame rowsNumber];r++)
    {
        for (int c = 0;c < [vgm.versusGame columnsNumber];c++)
        {
            if (vgm.versusGame.visible[r][c] != 0)
            {
                if (vgm.versusGame.board[r][c] == 9)
                {
                    MATCGlossyButton *buttonCell = (MATCGlossyButton *)[self.view viewWithTag:r * kJMSRow + c + kJMSRow];
                    [self removeSubViews: [buttonCell subviews]];
                    [self paintMine:(r * kJMSRow + c + kJMSRow) player: vgm.versusGame.visible[r][c] animation:NO];
                }
            }
        }
    }
}

-(void) resizeSubViews: (NSArray *) subviews
{
    for (UIView * subView in subviews)
    {
        [subView setFrame:CGRectMake((subView.frame.origin.x / subView.frame.size.width * cell_width ) , (subView.frame.origin.y / subView.frame.size.height * cell_height), cell_width, cell_height)];
    }
    
}

-(void) removeSubViews: (NSArray *) subviews
{
    for (UIView * subView in subviews)
    {
        [subView removeFromSuperview];
    }
    
}

-(void)loadBoard
{
    int cont = 0;
    
    [_boardScroll setContentSize:CGSizeMake([vgm.versusGame columnsNumber] * cell_width,
                                            [vgm.versusGame rowsNumber] * cell_height)];
    
    for (UIView * subView in [_boardScroll subviews])
    {
        [subView removeFromSuperview];
    }
    
    for (int i = 0; i < [vgm.versusGame rowsNumber]; i++)
    {
        for (int j = 0; j < [vgm.versusGame columnsNumber]; j++)
        {
            MATCGlossyButton *buttonCell  = [[MATCGlossyButton alloc] init];
            
            buttonCell.cornerRadius = 5.0f;
            [buttonCell setButtonColor: [UIColor colorWithRed:(155.0f / 255.0f)
                                                        green:(155.0f / 255.0f)
                                                         blue:(255.0f / 255.0f)
                                                        alpha:0.5f]];
            
            buttonCell.frame = CGRectMake((cell_width * j ) , (cell_height * i), cell_width, cell_height);
            [buttonCell setTag:(kJMSRow * i + j + kJMSRow)];
            [buttonCell setBackgroundColor: [UIColor clearColor]];
            [buttonCell setTitle: @"" forState:UIControlStateNormal];
            [buttonCell.titleLabel setFrame:buttonCell.frame];
            [buttonCell.titleLabel setBackgroundColor: [UIColor clearColor] ];
            [[buttonCell layer] setBorderColor:[[UIColor darkGrayColor] CGColor]];
            [[buttonCell layer] setBorderWidth:1.0f];
            [[buttonCell layer] setCornerRadius:5.0f];
            
            [buttonCell addTarget:self
                           action:@selector(selection:)
                 forControlEvents: UIControlEventTouchUpInside];
            
            [_boardScroll addSubview:buttonCell];
            
            cont++;
        }
    }
    
    [self updateMinesCounters];
}


- (void)scaleImage:(UIPinchGestureRecognizer *)recognizer
{
    if([recognizer state] == UIGestureRecognizerStateEnded)
    {
		_previousScale = 1.0;
        
		return;
	}
    
	CGFloat newScale = 1.0 - (_previousScale - [recognizer scale]);
    
    cell_height = cell_width = MIN(2 *(_boardScroll.frame.size.width / [vgm.versusGame columnsNumber]), cell_width * newScale);
    cell_height = cell_width = MAX((_boardScroll.frame.size.width / [vgm.versusGame columnsNumber]), cell_width);
    cell_height = MAX((_boardScroll.frame.size.height / [vgm.versusGame rowsNumber]), cell_height);
    [self reloadBoard];
}

- (void)paintMine:(NSInteger)tag
           player:(NSInteger)player
        animation:(BOOL)animation
{
    MATCGlossyButton *buttonCell = (MATCGlossyButton *)[self.view viewWithTag:tag];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0 , 0, cell_width, cell_height)];
    UIImageView *flag =  [[UIImageView alloc] initWithFrame:CGRectMake(cell_width/2 - 4 , 3/4*cell_height, cell_width/2, cell_height) ];
       
    switch (player)
    {
        case JMSPlayer1:
        {
            [flag setImage:[UIImage imageNamed:NSLocalizedString(@"IMG_PLAYER2", @"Background Image for the Player 2 found mine")]];
            
            break;
        }
        case JMSPlayer2:
        {
              [flag setImage:[UIImage imageNamed:NSLocalizedString(@"IMG_PLAYER1", @"Background Image for the Player 1 found mine")]];
            
            break;
        }
    }
   
    [containerView addSubview: flag];
    [buttonCell addSubview:containerView];

    if (animation)
    {
        CGPoint origin1 = containerView.center;
        CGPoint target1 = CGPointMake(containerView.center.x, containerView.center.y-5);
        CABasicAnimation *bounce1 = [CABasicAnimation animationWithKeyPath:@"position.y"];
        
        bounce1.fromValue = [NSNumber numberWithInt:origin1.y];
        bounce1.toValue = [NSNumber numberWithInt:target1.y];
        bounce1.duration = 1;
        bounce1.autoreverses = YES;
        bounce1.repeatCount = 2;
        
        [containerView.layer addAnimation:bounce1 forKey:@"position"];
        
        //Rotation Animation:
        CABasicAnimation *rota = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        
        rota.duration = 1;
        rota.autoreverses = YES;
        rota.removedOnCompletion = NO;
        rota.fromValue = [NSNumber numberWithFloat: -0.5];
        rota.toValue = [NSNumber numberWithFloat: 0.5 ];
        
        [flag.layer addAnimation: rota forKey: @"rotation"];
    }
}

- (void)paintCell:(NSInteger)tag
            title:(NSString *)title
{
    UIButton *buttonCell = (UIButton *)[self.view viewWithTag:tag];
    
    if (title.intValue == 0)
    {
        [buttonCell removeFromSuperview];
    }
    else
    {
        [buttonCell setTitle:title
                    forState:UIControlStateNormal];
        
        [buttonCell setTitleColor:[self getNumberColor:title]
                         forState:UIControlStateNormal];
    }
}

-(void) updateMinesCounters
{
    [_lblPlayer1Mines setText: [NSString stringWithFormat: @"%@", @([vgm.versusGame minesPlayer1])]];
    [Tools versionedScaleFactor:_lblPlayer1Mines factor:0.7 size:15];
    [Tools versionedTextAlignment:_lblPlayer1Mines alignment:NSTextAlignmentCenter];
    
    [_lblPlayer2Mines setText: [NSString stringWithFormat: @"%@", @([vgm.versusGame minesPlayer2])]];
    [Tools versionedScaleFactor:_lblPlayer2Mines factor:0.7 size:15];
    [Tools versionedTextAlignment:_lblPlayer2Mines alignment:NSTextAlignmentCenter];
    
    [_lblMines setText: [NSString stringWithFormat: @"%@", @([vgm.versusGame remainingMines])]];
    [Tools versionedScaleFactor:_lblMines factor:0.7 size:15];
    [Tools versionedTextAlignment:_lblMines alignment:NSTextAlignmentCenter];
}

-(UIColor *) getNumberColor: (NSString *) number
{
    UIColor * color = [UIColor clearColor];
    switch ([number intValue])
    {
        case 1: color = [UIColor blueColor];
            break;
        case 2: color = [UIColor redColor];
            break;
        case 3: color = [UIColor yellowColor];
            break;
        case 4: color = [UIColor blackColor];
            break;
        case 5: color = [UIColor orangeColor];
            break;
        case 6: color = [UIColor greenColor];
            break;
        case 7: color = [UIColor purpleColor];
            break;
        case 8: color = [UIColor magentaColor];
            break;
    }
    
    return color;
    
}

- (void)passTurn:(NSInteger)player
{
    switch (player)
    {
        case JMSPlayer1:
        {
            [[self.lblPlayer1 layer] setBorderColor:[[UIColor redColor] CGColor]];
            [[self.lblPlayer1 layer] setBorderWidth:2];
            
            [[self.lblPlayer2 layer] setBorderColor:[[UIColor clearColor] CGColor]];
            [[self.lblPlayer2 layer] setBorderWidth:0];
            
            break;
        }
        case JMSPlayer2:
        {
            [[self.lblPlayer2 layer] setBorderColor:[[UIColor redColor] CGColor]];
            [[self.lblPlayer2 layer] setBorderWidth:2];
            
            [[self.lblPlayer1 layer] setBorderColor:[[UIColor clearColor] CGColor]];
            [[self.lblPlayer1 layer] setBorderWidth:0];
            
            break;
        }
    }
}

- (void)goBack
{
    @try
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception)
    {
        DLog(@"ERROR on VersusViewController goBack:");
        NSLog(@"%@",exception);
    }
}

- (IBAction)showOptions:(id)sender
{
    UIActionSheet *optionsSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"STR_OptionsTitle", @"Text for options")
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:NSLocalizedString(@"bt_close", @"Close button text / dismisses the action sheet or alert")
                                                     otherButtonTitles:NSLocalizedString(@"bt_return", @"Return button text / closes the view returning to the previous one"), nil];
    
    [optionsSheet  showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)optionsSheet clickedButtonAtIndex:(NSInteger)optionIndex
{
    switch (optionIndex)
    {
        case 1:
        {
            [self goBack];
            
            break;
        }
    }
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    [bodyTextView resignFirstResponder];
    return NO;
}

-(void) dismissDisclaimer
{
    [disclaimerView removeFromSuperview];
}


@end
