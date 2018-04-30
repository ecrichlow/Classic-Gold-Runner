/*******************************************************************************
* Classic_Gold_RunnerViewController.m
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the implementation for the
*						application's primary view controller
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/02/08		*	EGC	*	File creation date
*******************************************************************************/

#import "Classic_Gold_RunnerViewController.h"
#import "Classic_Gold_RunnerAppDelegate.h"

@implementation Classic_Gold_RunnerViewController

@synthesize gameView;
@synthesize gameViewLarge;
@synthesize gameViewMedium;
@synthesize gameViewSmall;
@synthesize scoreText;
@synthesize scoreTextLarge;
@synthesize scoreTextMedium;
@synthesize scoreTextSmall;
@synthesize livesText;
@synthesize livesTextLarge;
@synthesize livesTextMedium;
@synthesize livesTextSmall;
@synthesize levelText;
@synthesize levelTextLarge;
@synthesize levelTextMedium;
@synthesize levelTextSmall;
@synthesize largeView;
@synthesize mediumView;
@synthesize smallView;
@synthesize curtain;
@synthesize curtainLarge;
@synthesize curtainMedium;
@synthesize curtainSmall;
@synthesize quitButton;
@synthesize quitButtonLarge;
@synthesize quitButtonMedium;
@synthesize quitButtonSmall;
@synthesize pauseButton;
@synthesize pauseButtonLarge;
@synthesize pauseButtonMedium;
@synthesize pauseButtonSmall;

#pragma mark - View Lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Business Logic

- (IBAction)pauseGame:(id)sender
{
	[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] pauseGame];
}

- (IBAction)quitGame:(id)sender
{
	[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] stopGame];
}

- (IBAction)leftDig:(id)sender
{

	if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] acceptingInput])
		{
		[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setRunner_dig:YES];
		}
}

- (IBAction)rightDig:(id)sender
{

	if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] acceptingInput])
		{
		[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setRunner_dig:YES];
		}
}

- (IBAction)middleDig:(id)sender
{

	if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] acceptingInput])
		{
		[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setRunner_dig:YES];
		}
}

- (IBAction)moveUp:(id)sender
{

	if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] acceptingInput])
		{
		if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] controlStyle] == CONTROL_STYLE_STICK)
			[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setController_dir:UP];
		else
			[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setUpButtonPressed:YES];
		}
}

- (IBAction)moveDown:(id)sender
{

	if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] acceptingInput])
		{
		if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] controlStyle] == CONTROL_STYLE_STICK)
			[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setController_dir:DOWN];
		else
			[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setDownButtonPressed:YES];
		}
}

- (IBAction)moveLeft:(id)sender
{

	if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] acceptingInput])
		{
		if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] controlStyle] == CONTROL_STYLE_STICK)
			[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setController_dir:LEFT];
		else
			[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setLeftButtonPressed:YES];
		}
}

- (IBAction)moveRight:(id)sender
{

	if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] acceptingInput])
		{
		if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] controlStyle] == CONTROL_STYLE_STICK)
			[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setController_dir:RIGHT];
		else
			[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setRightButtonPressed:YES];
		}
}

- (IBAction)moveStop:(id)sender
{

	if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] acceptingInput])
		{
		[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setController_dir:STOP];
		}
}

- (IBAction)stopMoveUp:(id)sender
{

	if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] acceptingInput])
		{
		[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setUpButtonPressed:NO];
		}
}

- (IBAction)stopMoveDown:(id)sender
{

	if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] acceptingInput])
		{
		[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setDownButtonPressed:NO];
		}
}

- (IBAction)stopMoveLeft:(id)sender
{

	if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] acceptingInput])
		{
		[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setLeftButtonPressed:NO];
		}
}

- (IBAction)stopMoveRight:(id)sender
{

	if ([(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] acceptingInput])
		{
		[(Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate] setRightButtonPressed:NO];
		}
}

- (void)setStats:(unsigned int)score level:(short)level lives:(short)lives;
{

	scoreText.text = [[NSNumber numberWithUnsignedInt:score] stringValue];
	livesText.text = [[NSNumber numberWithShort:lives] stringValue];
	levelText.text = [[NSNumber numberWithShort:level] stringValue];
}

- (void)setViewType:(int)viewType
{

	if (viewType == BUTTON_SIZE_LARGE)
		{
		self.view = largeView;
		gameView = gameViewLarge;
		scoreText = scoreTextLarge;
		livesText = livesTextLarge;
		levelText = levelTextLarge;
		curtain = curtainLarge;
		quitButton = quitButtonLarge;
		pauseButton = pauseButtonLarge;
		}
	else if (viewType == BUTTON_SIZE_MEDIUM)
		{
		self.view = mediumView;
		gameView = gameViewMedium;
		scoreText = scoreTextMedium;
		livesText = livesTextMedium;
		levelText = levelTextMedium;
		curtain = curtainMedium;
		quitButton = quitButtonMedium;
		pauseButton = pauseButtonMedium;
		}
	else if (viewType == BUTTON_SIZE_SMALL)
		{
		self.view = smallView;
		gameView = gameViewSmall;
		scoreText = scoreTextSmall;
		livesText = livesTextSmall;
		levelText = levelTextSmall;
		curtain = curtainSmall;
		quitButton = quitButtonSmall;
		pauseButton = pauseButtonSmall;
		}
	else if (viewType == BUTTON_SIZE_HORIZONTAL)
		{
		self.view = horizontalView;
		gameView = gameViewHorizontal;
		scoreText = scoreTextHorizontal;
		livesText = livesTextHorizontal;
		levelText = levelTextHorizontal;
		curtain = curtainHorizontal;
		quitButton = quitButtonHorizontal;
		pauseButton = pauseButtonHorizontal;
		}
}

@end
