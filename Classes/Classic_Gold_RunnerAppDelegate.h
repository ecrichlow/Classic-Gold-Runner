/*******************************************************************************
* Classic_Gold_RunnerAppDelegate.h
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the template for the
*						application's delegated methods
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/02/08		*	EGC	*	File creation date
*******************************************************************************/

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Palette.h"
#import "RawImage.h"
#import "Gameboard.h"
#import "ImageSet.h"
#import "Character.h"
#import "FlickView.h"

#define DEFAULT_PALETTE_FILE		@"classic_256.pal"
#define TITLE_IMAGE_FILE			@"title_256"
#define INTRO_IMAGE_FILE			@"intro_256"
#define IOG_TITLE_IMAGE_FILE		@"IoGTitle.png"

#define INTRO_WIDTH					160
#define INTRO_HEIGHT				64
#define TITLE_WIDTH					256
#define TITLE_HEIGHT				80
#define BOARD_WIDTH					256
#define BOARD_HEIGHT				171

@class Classic_Gold_RunnerViewController;

@interface Classic_Gold_RunnerAppDelegate : NSObject <UIApplicationDelegate, AVAudioPlayerDelegate>
{

	IBOutlet UIWindow								*window;
	IBOutlet Classic_Gold_RunnerViewController		*gamePlayViewController;
	IBOutlet UIViewController						*highScoreScreenController;
	IBOutlet UIViewController						*preferencesScreenController;
	IBOutlet UIViewController						*instructionsScreenController;
	IBOutlet UIViewController						*startLevelScreenController;
	IBOutlet UIImageView							*HSTitleView;
	IBOutlet UIView									*HSList;
	IBOutlet UIImageView							*gameScreenView;
	IBOutlet UIView									*enterHSView;
	IBOutlet UITextField							*highScoreName;
	IBOutlet UIImageView							*curtainView;
	IBOutlet UISegmentedControl						*buttonSizeControl;
	IBOutlet UISegmentedControl						*screenOrientationControl;
	IBOutlet UISegmentedControl						*controlStyleControl;
	IBOutlet UISlider								*startLevelControl;
	IBOutlet UITextField							*startLevelDisplay;

	Palette									*customPalette;				// Current color palette used by all graphics in the game
	RawImage								*titleImage;				// Image to be displayed at the top of the High Score screen
	int										currentLevel;				// Level the player is currently on
	Gameboard								*currentBoard;				// Currently loaded gameboard
	ImageSet								*currentTileset;			// Current tile set, stored so we can re-use it instead of re-loading it between gameboards
	NSString								*currentTileFilename;		// Name of current tile set, stored so we can compare it to future tile sets, for possible re-use
	ImageSet								*currentSpriteset;			// Current sprite set, stored so we can re-use it instead of re-loading it between gameboards
	NSString								*currentSpriteFilename;		// Name of current tile set, stored so we can compare it to future tile sets, for possible re-use
	UIImage									*staticBackground;			// Gameboard image which doesn't change much and gets blitted to the frame before each screen-flip
	UIImage									*frame;						// Canvas used to draw each frame before blitting to the screen
	short									controller_dir;				// Tracks the current direction the controller is pointing
	Character								*runner;					// Character object representing the player
	NSMutableArray							*guards;					// Collection of all the guards for the level
	short									brd_x_exit;					// X-Axis coordinate of the escape ladder's start point
	short									brd_y_exit;					// Y-Axis coordinate of the escape ladder's start point
	struct gold_position					gold_start[MAX_GOLD];		// Starting position of a gold bar on the level
	int										level_gold;					// Number of pieces of gold on the level
	unsigned int							max_block_move;				// Number of blocks in a transitional (digging) state
	BOOL									dead;						// Determines whether or not player has died
	BOOL									escapable;					// Set once all of the gold has been collected and escape ladder is placed
	short									game_mode;					// The state the game is currently in
	struct start_players					player[MAX_CHARACTERS];		// Starting position of all of the characters on the level
	short									num_guards;					// Number of guards on the level
	unsigned int							score;						// score this iteration through the game loop
	unsigned int							last_score;					// score last iteration through the game loop
	BOOL									runner_dig;					// Was a global, determines if the runner is currently digging
	NSTimer									*updateTimer;				// Updates the frame on a regular basis
	NSMutableArray							*spriteViews;				// Array of UIImageView objects for the various sprites that need to be displayed
	short									runner_lives;				// Number of lives the player has left
	short									level;						// Current level
	BOOL									leftButtonPressed;			// Used for tracking multiple buttons depressed simultaneously
	BOOL									rightButtonPressed;			// Used for tracking multiple buttons depressed simultaneously
	BOOL									upButtonPressed;			// Used for tracking multiple buttons depressed simultaneously
	BOOL									downButtonPressed;			// Used for tracking multiple buttons depressed simultaneously
	NSMutableArray							*highScores;				// Set of top 10 high scores
	int										mostRecentHighScore;		// Used to determine which score to highlight
	NSMutableArray							*highScoreEntries;			// Contains the set of views used to hold the high score entries
	NSTimer									*animationTimer;			// Updates the high score animation
	int										animationFrame;				// Stores which frame of the animation last displayed
	UIView									*HSOverlayView;				// Contains the scrolling high score overlay
	UIView									*normalHS;					// Contains a copy of the original version of the current high score
	UIView									*invertedHS;				// Contains the inverted version of the current high score
	NSTimer									*curtainTimer;				// Reveals the curtain gradually
	int										curtainPull;				// Number of iterations through the curtain reveal loop
	UIImage									*background;				// The image used for the background in the reveal curtain
	UIImage									*spotlight;					// The image used for the trasnparency in the reveal curtain
	int										buttonSize;					// Index of the button size preference
	int										screenOrientation;			// Index of the screen orientation preference
	int										controlStyle;				// Index of the control style preference
	int										defaultStartLevel;			// Start level preference
	int										maxLevel;					// Maximum level reached preference
	CGPoint									touchStartPosition;			// Position at the beginning of a touch event
	FlickView								*flickView;					// View designed to capture touch events
	BOOL									acceptingInput;				// Flag set during times like game paused, where input should be ignored
	AVAudioPlayer							*audioPlayer;				// Placeholder for an often alloc'd and dealloc'd audio player

}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Classic_Gold_RunnerViewController *gamePlayViewController;
@property (nonatomic, retain) IBOutlet UIViewController *highScoreScreenController;
@property (nonatomic, retain) IBOutlet UIViewController *preferencesScreenController;
@property (nonatomic, retain) IBOutlet UIViewController *instructionsScreenController;
@property (nonatomic, retain) IBOutlet UIViewController *startLevelScreenController;
@property (nonatomic, retain) IBOutlet UIImageView *HSTitleView;
@property (nonatomic, retain) IBOutlet UIView *HSList;
@property (nonatomic, retain) IBOutlet UIImageView *gameScreenView;
@property (nonatomic, retain) IBOutlet UIView *enterHSView;
@property (nonatomic, retain) IBOutlet UITextField *highScoreName;
@property (nonatomic, retain) IBOutlet UIView *curtainView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *buttonSizeControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *screenOrientationControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *controlStyleControl;
@property (nonatomic, retain) IBOutlet UISlider *startLevelControl;
@property (nonatomic, retain) IBOutlet UITextField *startLevelDisplay;
@property (nonatomic, retain) Palette *customPalette;
@property (nonatomic, retain) NSString *currentTileFilename;
@property (nonatomic, retain) NSString *currentSpriteFilename;
@property (nonatomic, retain) UIView *HSOverlayView;
@property (nonatomic, retain) UIView *normalHS;
@property (nonatomic, retain) UIView *invertedHS;
- (IBAction)showPreferences:(id)sender;
- (IBAction)showInstructions:(id)sender;
- (IBAction)setStartLevel:(id)sender;
- (IBAction)startGame:(id)sender;
- (IBAction)acceptHighScore:(id)sender;
- (IBAction)cancelHighScore:(id)sender;
- (IBAction)closePreferences:(id)sender;
- (IBAction)closeInstructions:(id)sender;
- (IBAction)closeSetStartLevel:(id)sender;
- (void)readPreferences;
- (void)writePrefsFile;
- (void)readHighScores;
- (void)writeHSFile;
- (void)pauseGame;
- (void)stopGame;
- (void)showHighScores;
- (void)setupHighScoreAnimation;
- (void)updateHSAnimation:(NSTimer *)timer;
- (void)startHSTimer;
- (void)stopHSTimer;
- (void)startReveal;
- (void)revealCurtain:(NSTimer *)timer;
- (void)finishReveal;
- (void)Start_Level;
- (void)updateFrame:(NSTimer *)timer;
- (void)Update_Display;
- (void)Draw_Characters;
- (void)playSound:(int)soundNum;
- (void)loadBackgroundImage;
- (void)loadLevelStats;
- (void)Process_Objects;
- (void)Remove_Escape;
- (void)Runner_Die;
- (void)Guard_Die:(NSUInteger)guardNum;
- (void)Collision_Detection;
- (void)Reveal_Escape;
- (BOOL)Dig_Hole;
- (void)Win_Board;
- (NSMutableArray *)guards;
- (short)controller_dir;
- (Character *)runner;
- (Gameboard *)currentBoard;
- (int)max_block_move;
- (BOOL)runner_dig;
- (void)setController_dir:(short)newDir;
- (void)setRunner_dig:(BOOL)newDig;
- (void)incrementScore:(int)addToScore;
- (void)incrementMaxBlockMove;
- (void)Enter_High_Score;
- (void)setLeftButtonPressed:(BOOL)state;
- (void)setRightButtonPressed:(BOOL)state;
- (void)setUpButtonPressed:(BOOL)state;
- (void)setDownButtonPressed:(BOOL)state;
- (void)setTouchStartPosition:(CGPoint)startPoint;
- (BOOL)upButtonPressed;
- (BOOL)downButtonPressed;
- (BOOL)leftButtonPressed;
- (BOOL)rightButtonPressed;
- (int)screenOrientation;
- (int)controlStyle;
- (BOOL)acceptingInput;
@end

