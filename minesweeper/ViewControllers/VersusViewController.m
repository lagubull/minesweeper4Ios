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

@property (nonatomic, strong) VersusGameManager *versusGameManager;

@property (nonatomic, strong) UIView *disclaimerView;

@property (nonatomic, strong) UITextView *bodyTextView;

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, assign) CGFloat cellWidth;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

- (void)setupLabels;

- (void)reloadBoard;

- (void)resizeSubviews:(NSArray *)subviews;

- (void)removeSubviews:(NSArray *)subviews;

- (void)scaleImage:(UIPinchGestureRecognizer *)recognizer;

- (void)paintMine:(NSInteger)tag
           player:(NSInteger)player
        animation:(BOOL)animation;

- (void)paintCell:(NSInteger)tag
            title:(NSString *)title;

- (UIColor *)getNumberColor:(NSString *)number;

- (void)goBack;

- (void)dismissDisclaimer;

@end

@implementation VersusViewController

#pragma  mark - ViewLifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:self.pinchGesture];
    
    [self.navigationController setNavigationBarHidden:YES
                                             animated:NO];
    
    [self setupLabels];
    
    [self.versusGameManager setupGame];
}

#pragma mark - setupLabels

- (void)setupLabels
{
    self.lblRemainingMines.text = NSLocalizedString(@"MINES_LEFT", @"Remaining mines");
    
    [Tools versionedScaleFactor:self.lblRemainingMines
                         factor:0.7f
                           size:15];
    
    [Tools versionedTextAlignment:self.lblRemainingMines
                        alignment:NSTextAlignmentCenter];
    
    self.lblPlayer1.text = [NSString stringWithUTF8String:[[NSString stringWithFormat:@" %@:",
                                                            NSLocalizedString(@"PLAYER_1", @"Player 1 text")] UTF8String]];
    
    [Tools versionedScaleFactor:self.lblPlayer1
                         factor:0.7f
                           size:15];
    
    [Tools versionedTextAlignment:self.lblPlayer1
                        alignment:NSTextAlignmentLeft];
    
    self.lblPlayer2.text = [NSString stringWithUTF8String:[[NSString stringWithFormat: @" %@:",
                                                            NSLocalizedString(@"PLAYER_2",@"Player 2 text")] UTF8String]];
    
    [Tools versionedScaleFactor:self.lblPlayer2
                         factor:0.7f
                           size:15];
    
    [Tools versionedTextAlignment:self.lblPlayer2
                        alignment:NSTextAlignmentLeft];
}


#pragma mark - Getters

- (VersusGameManager *)versusGameManager
{
    if (!_versusGameManager)
    {
        _versusGameManager = [[VersusGameManager alloc] init];
        _versusGameManager.versusViewController = self;
        
        _versusGameManager.versusGame = self.versusGame;
    }
    
    return _versusGameManager;
}

- (CGFloat)cellHeight
{
    if (_cellHeight == 0.0f)
    {
        _cellHeight = self.boardScroll.frame.size.width / self.versusGameManager.versusGame.columnsNumber;
        
        _cellHeight = MIN (2.0f * (self.boardScroll.frame.size.width / self.versusGameManager.versusGame.columnsNumber), _cellHeight);
        _cellHeight = MAX ((self.boardScroll.frame.size.width / self.versusGameManager.versusGame.columnsNumber), _cellHeight);
        _cellHeight = MAX ((self.boardScroll.frame.size.height / self.versusGameManager.versusGame.rowsNumber), _cellHeight);
    }
    
    return _cellHeight;
}

- (CGFloat)cellWidth
{
    if (_cellWidth == 0.0f)
    {
        _cellWidth = self.cellHeight;
    }
    
    return _cellWidth;
}

- (UIPinchGestureRecognizer *)pinchGesture
{
    if (!_pinchGesture)
    {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(scaleImage:)];
    }
    
    return _pinchGesture;
}

#pragma mark - ButtonActions

- (IBAction)selection:(id)sender
{
    [self.versusGameManager cellSelected:((UIButton *)sender).tag];
}

#pragma mark - LoadBoard

- (void)loadBoard
{
    int cont = 0;
    
    [self.boardScroll setContentSize:CGSizeMake([self.versusGameManager.versusGame columnsNumber] * self.cellWidth,
                                                [self.versusGameManager.versusGame rowsNumber] * self.cellHeight)];
    
    for (UIView * subView in self.boardScroll.subviews)
    {
        [subView removeFromSuperview];
    }
    
    for (NSInteger i = 0; i < self.versusGameManager.versusGame.rowsNumber; i++)
    {
        for (NSInteger j = 0; j < self.versusGameManager.versusGame.columnsNumber; j++)
        {
            MATCGlossyButton *buttonCell = [[MATCGlossyButton alloc] init];
            
            buttonCell.cornerRadius = 5.0f;
            [buttonCell setButtonColor: [UIColor colorWithRed:(155.0f / 255.0f)
                                                        green:(155.0f / 255.0f)
                                                         blue:(255.0f / 255.0f)
                                                        alpha:0.5f]];
            
            buttonCell.frame = CGRectMake((self.cellWidth * j),
                                          (self.cellHeight * i),
                                          self.cellWidth,
                                          self.cellHeight);
            
            buttonCell.tag = (kJMSRow * i + j + kJMSRow);
            buttonCell.backgroundColor = [UIColor clearColor];
            
            [buttonCell setTitle:@""
                        forState:UIControlStateNormal];
            
            buttonCell.titleLabel.frame = buttonCell.frame;
            buttonCell.titleLabel.backgroundColor = [UIColor clearColor];
            
            buttonCell.layer.borderColor = [UIColor darkGrayColor].CGColor;
            buttonCell.layer.borderWidth = 1.0f;
            buttonCell.layer.cornerRadius = 5.0f;
            
            [buttonCell addTarget:self
                           action:@selector(selection:)
                 forControlEvents: UIControlEventTouchUpInside];
            
            [self.boardScroll addSubview:buttonCell];
            
            cont++;
        }
    }
    
    [self updateMinesCounters];
}

#pragma mark - ReloadBoard

- (void)reloadBoard
{
    [self.boardScroll setContentSize:CGSizeMake(self.versusGameManager.versusGame.columnsNumber * self.cellWidth,
                                                self.versusGameManager.versusGame.rowsNumber * self.cellHeight)];
    
    [self resizeSubviews:[self.boardScroll subviews]];
    
    for (NSInteger row = 0; row < self.versusGameManager.versusGame.rowsNumber; row++)
    {
        for (NSInteger column = 0; column < self.versusGameManager.versusGame.columnsNumber; column++)
        {
            if (self.versusGameManager.versusGame.visible[row][column] != 0)
            {
                if (self.versusGameManager.versusGame.board[row][column] == 9)
                {
                    MATCGlossyButton *buttonCell = (MATCGlossyButton *)[self.view viewWithTag:row * kJMSRow + column + kJMSRow];
                    
                    [self removeSubviews:buttonCell.subviews];
                    
                    [self paintMine:(row * kJMSRow + column + kJMSRow)
                             player:self.versusGameManager.versusGame.visible[row][column]
                          animation:NO];
                }
            }
        }
    }
}

#pragma mark - ResizeSubiews

- (void)resizeSubviews:(NSArray *)subviews
{
    for (UIView * subView in subviews)
    {
        [subView setFrame:CGRectMake((subView.frame.origin.x / subView.frame.size.width * self.cellWidth),
                                     (subView.frame.origin.y / subView.frame.size.height * self.cellHeight),
                                     self.cellWidth,
                                     self.cellHeight)];
    }
}

#pragma mark - RemoveSubviews

- (void)removeSubviews:(NSArray *)subviews
{
    for (UIView * subView in subviews)
    {
        [subView removeFromSuperview];
    }
}

#pragma mark - ScaleImage

- (void)scaleImage:(UIPinchGestureRecognizer *)recognizer
{
    if([recognizer state] == UIGestureRecognizerStateEnded)
    {
        self.previousScale = 1.0f;
        
        return;
    }
    
    CGFloat newScale = 1.0f - (self.previousScale - recognizer.scale);
    
    self.cellHeight = self.cellWidth = MIN(2.0f *(self.boardScroll.frame.size.width / self.versusGameManager.versusGame.columnsNumber), self.cellWidth * newScale);
    
    self.cellHeight = self.cellWidth = MAX((self.boardScroll.frame.size.width / self.versusGameManager.versusGame.columnsNumber), self.cellWidth);
    
    self.cellHeight = MAX((self.boardScroll.frame.size.height / self.versusGameManager.versusGame.rowsNumber), self.cellHeight);
    
    [self reloadBoard];
}

#pragma mark - PaintMine

- (void)paintMine:(NSInteger)tag
           player:(NSInteger)player
        animation:(BOOL)animation
{
    MATCGlossyButton *buttonCell = (MATCGlossyButton *)[self.view viewWithTag:tag];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     self.cellWidth,
                                                                     self.cellHeight)];
    
    UIImageView *flag = [[UIImageView alloc] initWithFrame:CGRectMake((self.cellWidth / 2 - 4),
                                                                       (3 / 4 * self.cellHeight),
                                                                       self.cellWidth / 2,
                                                                       self.cellHeight)];
    
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
        
        CGPoint target1 = CGPointMake(containerView.center.x,
                                      containerView.center.y - 5);
        
        CABasicAnimation *bounce1 = [CABasicAnimation animationWithKeyPath:@"position.y"];
        
        bounce1.fromValue = [NSNumber numberWithInt:origin1.y];
        bounce1.toValue = [NSNumber numberWithInt:target1.y];
        bounce1.duration = 1;
        bounce1.autoreverses = YES;
        bounce1.repeatCount = 2;
        
        [containerView.layer addAnimation:bounce1
                                   forKey:@"position"];
        
        //Rotation Animation:
        CABasicAnimation *retation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        
        retation.duration = 1;
        retation.autoreverses = YES;
        retation.removedOnCompletion = NO;
        retation.fromValue = [NSNumber numberWithFloat:-0.5];
        retation.toValue = [NSNumber numberWithFloat:0.5 ];
        
        [flag.layer addAnimation:retation
                          forKey:@"rotation"];
    }
}

#pragma mark - paintCell

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

#pragma mark - UpdateMinesCounters

-(void)updateMinesCounters
{
    self.lblPlayer1Mines.text = [NSString stringWithFormat:@"%@", @(self.versusGameManager.versusGame.minesPlayer1)];
    
    [Tools versionedScaleFactor:self.lblPlayer1Mines
                         factor:0.7
                           size:15];
    
    [Tools versionedTextAlignment:self.lblPlayer1Mines
                        alignment:NSTextAlignmentCenter];
    
    /*-----------*/
    
    self.lblPlayer2Mines.text = [NSString stringWithFormat:@"%@", @(self.versusGameManager.versusGame.minesPlayer2)];
    
    [Tools versionedScaleFactor:self.lblPlayer2Mines
                         factor:0.7
                           size:15];
    
    [Tools versionedTextAlignment:self.lblPlayer2Mines
                        alignment:NSTextAlignmentCenter];
    
    /*-----------*/
    
    self.lblMines.text = [NSString stringWithFormat:@"%@", @(self.versusGameManager.versusGame.remainingMines)];
    
    [Tools versionedScaleFactor:self.lblMines
                         factor:0.7
                           size:15];
    
    [Tools versionedTextAlignment:self.lblMines
                        alignment:NSTextAlignmentCenter];
}

#pragma mark - GetNumberColor

- (UIColor *)getNumberColor:(NSString *)number
{
    UIColor *color = [UIColor clearColor];
    
    switch (number.intValue)
    {
        case 1:
        {
            color = [UIColor blueColor];
            
            break;
        }
        case 2:
        {
            color = [UIColor redColor];
            
            break;
        }
        case 3:
        {
            color = [UIColor yellowColor];
            
            break;
        }
        case 4:
        {
            color = [UIColor blackColor];
            
            break;
        }
        case 5:
        {
            color = [UIColor orangeColor];
            
            break;
        }
        case 6:
        {
            color = [UIColor greenColor];
            
            break;
        }
        case 7:
        {
            color = [UIColor purpleColor];
            
            break;
        }
        case 8:
        {
            color = [UIColor magentaColor];
            
            break;
        }
    }
    
    return color;
    
}

#pragma mark - PassTurn

- (void)passTurn:(NSInteger)player
{
    switch (player)
    {
        case JMSPlayer1:
        {
            self.lblPlayer1.layer.borderColor = [UIColor redColor].CGColor;
            self.lblPlayer1.layer.borderWidth = 2.0f;
            
            self.lblPlayer2.layer.borderColor = [UIColor clearColor].CGColor;
            self.lblPlayer2.layer.borderWidth = 0.0f;
            
            break;
        }
        case JMSPlayer2:
        {
            self.lblPlayer2.layer.borderColor = [UIColor redColor].CGColor;
            self.lblPlayer2.layer.borderWidth = 2.0f;
            
            self.lblPlayer1.layer.borderColor = [UIColor clearColor].CGColor;
            self.lblPlayer1.layer.borderWidth = 0.0f;
            
            break;
        }
    }
}

#pragma mark - GoBack

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

#pragma mark - ShowOptions

- (IBAction)showOptions:(id)sender
{
    UIActionSheet *optionsSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"STR_OptionsTitle", @"Text for options")
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:NSLocalizedString(@"bt_close", @"Close button text / dismisses the action sheet or alert")
                                                     otherButtonTitles:NSLocalizedString(@"bt_return", @"Return button text / closes the view returning to the previous one"), nil];
    
    [optionsSheet  showInView:self.view];
}

#pragma mark - ActionSheetDelegate

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

#pragma mark - UIResponder

- (BOOL)canPerformAction:(SEL)action
             withSender:(id)sender
{
    [self.bodyTextView resignFirstResponder];
    
    return NO;
}

#pragma mark - DissmissDisclaimer

- (void)dismissDisclaimer
{
    [self.disclaimerView removeFromSuperview];
}

@end
