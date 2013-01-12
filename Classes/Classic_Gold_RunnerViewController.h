/*******************************************************************************
* Classic_Gold_RunnerViewController.h
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the template for the
*						application's primary view controller
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/02/08		*	EGC	*	File creation date
*******************************************************************************/

#import <UIKit/UIKit.h>

@interface Classic_Gold_RunnerViewController : UIViewController
{

	IBOutlet UIImageView							*gameView;
	IBOutlet UIImageView							*gameViewLarge;
	IBOutlet UIImageView							*gameViewMedium;
	IBOutlet UIImageView							*gameViewSmall;
	IBOutlet UIImageView							*gameViewHorizontal;
	IBOutlet UILabel								*scoreText;
	IBOutlet UILabel								*scoreTextLarge;
	IBOutlet UILabel								*scoreTextMedium;
	IBOutlet UILabel								*scoreTextSmall;
	IBOutlet UILabel								*scoreTextHorizontal;
	IBOutlet UILabel								*livesText;
	IBOutlet UILabel								*livesTextLarge;
	IBOutlet UILabel								*livesTextMedium;
	IBOutlet UILabel								*livesTextSmall;
	IBOutlet UILabel								*livesTextHorizontal;
	IBOutlet UILabel								*levelText;
	IBOutlet UILabel								*levelTextLarge;
	IBOutlet UILabel								*levelTextMedium;
	IBOutlet UILabel								*levelTextSmall;
	IBOutlet UILabel								*levelTextHorizontal;
	IBOutlet UIButton								*quitButton;
	IBOutlet UIButton								*quitButtonLarge;
	IBOutlet UIButton								*quitButtonMedium;
	IBOutlet UIButton								*quitButtonSmall;
	IBOutlet UIButton								*quitButtonHorizontal;
	IBOutlet UIButton								*pauseButton;
	IBOutlet UIButton								*pauseButtonLarge;
	IBOutlet UIButton								*pauseButtonMedium;
	IBOutlet UIButton								*pauseButtonSmall;
	IBOutlet UIButton								*pauseButtonHorizontal;
	IBOutlet UIView									*largeView;				// Large controls
	IBOutlet UIView									*mediumView;			// Medium controls
	IBOutlet UIView									*smallView;				// Small controls
	IBOutlet UIView									*horizontalView;		// Horizontal display
	IBOutlet UIImageView							*curtain;				// Reveal curtain for the selected size
	IBOutlet UIImageView							*curtainLarge;			// Large reveal curtain
	IBOutlet UIImageView							*curtainMedium;			// Medium reveal curtain
	IBOutlet UIImageView							*curtainSmall;			// Small reveal curtain
	IBOutlet UIImageView							*curtainHorizontal;		// Horizontal reveal curtain

}
@property (nonatomic, retain) IBOutlet UIImageView *gameView;
@property (nonatomic, retain) IBOutlet UIImageView *gameViewLarge;
@property (nonatomic, retain) IBOutlet UIImageView *gameViewMedium;
@property (nonatomic, retain) IBOutlet UIImageView *gameViewSmall;
@property (nonatomic, retain) IBOutlet UILabel *scoreText;
@property (nonatomic, retain) IBOutlet UILabel *scoreTextLarge;
@property (nonatomic, retain) IBOutlet UILabel *scoreTextMedium;
@property (nonatomic, retain) IBOutlet UILabel *scoreTextSmall;
@property (nonatomic, retain) IBOutlet UILabel *livesText;
@property (nonatomic, retain) IBOutlet UILabel *livesTextLarge;
@property (nonatomic, retain) IBOutlet UILabel *livesTextMedium;
@property (nonatomic, retain) IBOutlet UILabel *livesTextSmall;
@property (nonatomic, retain) IBOutlet UILabel *levelText;
@property (nonatomic, retain) IBOutlet UILabel *levelTextLarge;
@property (nonatomic, retain) IBOutlet UILabel *levelTextMedium;
@property (nonatomic, retain) IBOutlet UILabel *levelTextSmall;
@property (nonatomic, retain) IBOutlet UIButton *quitButton;
@property (nonatomic, retain) IBOutlet UIButton *quitButtonLarge;
@property (nonatomic, retain) IBOutlet UIButton *quitButtonMedium;
@property (nonatomic, retain) IBOutlet UIButton *quitButtonSmall;
@property (nonatomic, retain) IBOutlet UIButton *pauseButton;
@property (nonatomic, retain) IBOutlet UIButton *pauseButtonLarge;
@property (nonatomic, retain) IBOutlet UIButton *pauseButtonMedium;
@property (nonatomic, retain) IBOutlet UIButton *pauseButtonSmall;
@property (nonatomic, retain) IBOutlet UIView *largeView;
@property (nonatomic, retain) IBOutlet UIView *mediumView;
@property (nonatomic, retain) IBOutlet UIView *smallView;
@property (nonatomic, retain) IBOutlet UIImageView *curtain;
@property (nonatomic, retain) IBOutlet UIImageView *curtainLarge;
@property (nonatomic, retain) IBOutlet UIImageView *curtainMedium;
@property (nonatomic, retain) IBOutlet UIImageView *curtainSmall;
- (IBAction)pauseGame:(id)sender;
- (IBAction)quitGame:(id)sender;
- (IBAction)leftDig:(id)sender;
- (IBAction)rightDig:(id)sender;
- (IBAction)middleDig:(id)sender;
- (IBAction)moveUp:(id)sender;
- (IBAction)moveDown:(id)sender;
- (IBAction)moveLeft:(id)sender;
- (IBAction)moveRight:(id)sender;
- (IBAction)moveStop:(id)sender;
- (IBAction)stopMoveUp:(id)sender;
- (IBAction)stopMoveDown:(id)sender;
- (IBAction)stopMoveLeft:(id)sender;
- (IBAction)stopMoveRight:(id)sender;
- (void)setStats:(unsigned int)score level:(short)level lives:(short)lives;
- (void)setViewType:(int)viewType;
- (void)setupFlickInput;
@end

