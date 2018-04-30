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
*	04/24/18		*	EGC *	Converted to ARC
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
@property (nonatomic, strong) IBOutlet UIImageView *gameView;
@property (nonatomic, strong) IBOutlet UIImageView *gameViewLarge;
@property (nonatomic, strong) IBOutlet UIImageView *gameViewMedium;
@property (nonatomic, strong) IBOutlet UIImageView *gameViewSmall;
@property (nonatomic, strong) IBOutlet UILabel *scoreText;
@property (nonatomic, strong) IBOutlet UILabel *scoreTextLarge;
@property (nonatomic, strong) IBOutlet UILabel *scoreTextMedium;
@property (nonatomic, strong) IBOutlet UILabel *scoreTextSmall;
@property (nonatomic, strong) IBOutlet UILabel *livesText;
@property (nonatomic, strong) IBOutlet UILabel *livesTextLarge;
@property (nonatomic, strong) IBOutlet UILabel *livesTextMedium;
@property (nonatomic, strong) IBOutlet UILabel *livesTextSmall;
@property (nonatomic, strong) IBOutlet UILabel *levelText;
@property (nonatomic, strong) IBOutlet UILabel *levelTextLarge;
@property (nonatomic, strong) IBOutlet UILabel *levelTextMedium;
@property (nonatomic, strong) IBOutlet UILabel *levelTextSmall;
@property (nonatomic, strong) IBOutlet UIButton *quitButton;
@property (nonatomic, strong) IBOutlet UIButton *quitButtonLarge;
@property (nonatomic, strong) IBOutlet UIButton *quitButtonMedium;
@property (nonatomic, strong) IBOutlet UIButton *quitButtonSmall;
@property (nonatomic, strong) IBOutlet UIButton *pauseButton;
@property (nonatomic, strong) IBOutlet UIButton *pauseButtonLarge;
@property (nonatomic, strong) IBOutlet UIButton *pauseButtonMedium;
@property (nonatomic, strong) IBOutlet UIButton *pauseButtonSmall;
@property (nonatomic, strong) IBOutlet UIView *largeView;
@property (nonatomic, strong) IBOutlet UIView *mediumView;
@property (nonatomic, strong) IBOutlet UIView *smallView;
@property (nonatomic, strong) IBOutlet UIImageView *curtain;
@property (nonatomic, strong) IBOutlet UIImageView *curtainLarge;
@property (nonatomic, strong) IBOutlet UIImageView *curtainMedium;
@property (nonatomic, strong) IBOutlet UIImageView *curtainSmall;
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
@end

