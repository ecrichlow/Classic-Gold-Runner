/*******************************************************************************
* Classic_Gold_RunnerAppDelegate.m
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the implementation for the
*						application's delegated methods
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/02/08		*	EGC	*	File creation date
*	04/23/18		*	EGC *	Updated to properly access embedded resources
*	04/24/18		*	EGC *	Converted to ARC
*	04/28/18		*	EGC	*	Changed implementation of FlickView so that
*								it works without moving pause and quit buttons
*								between parent views
*******************************************************************************/

#import "Classic_Gold_RunnerAppDelegate.h"
#import "Classic_Gold_RunnerViewController.h"

struct escape_block exit_block[BOARD_MAXHEIGHT];
struct place_block block_move[MAX_MOVE_BLOCKS];
struct object objs[MAX_OBJECTS];

@implementation Classic_Gold_RunnerAppDelegate

@synthesize window;
@synthesize gamePlayViewController;
@synthesize highScoreScreenController;
@synthesize preferencesScreenController;
@synthesize instructionsScreenController;
@synthesize startLevelScreenController;
@synthesize HSTitleView;
@synthesize HSList;
@synthesize gameScreenView;
@synthesize customPalette;
@synthesize currentTileFilename;
@synthesize currentSpriteFilename;
@synthesize enterHSView;
@synthesize highScoreName;
@synthesize HSOverlayView;
@synthesize normalHS;
@synthesize invertedHS;
@synthesize curtainView;
@synthesize buttonSizeControl;
@synthesize screenOrientationControl;
@synthesize controlStyleControl;
@synthesize startLevelControl;
@synthesize startLevelDisplay;

#pragma mark - Application Lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{

	unsigned int seed;

	// Setup
	seed = (unsigned int)[[NSDate date] timeIntervalSince1970];
	srandom(seed);
	[self readPreferences];
	[self readHighScores];
	enterHSView.frame = CGRectMake(ENTER_HS_XPOS, ENTER_HS_YPOS, HS_VIEW_WIDTH, HS_VIEW_HEIGHT);
	HSOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, HS_ENTRY_WIDTH, HS_ENTRY_HEIGHT)];
	HSOverlayView.clipsToBounds = YES;
	[HSList addSubview:HSOverlayView];
	customPalette = [[Palette alloc] init];
	[customPalette loadPalette:DEFAULT_PALETTE_FILE];
	titleImage = [[RawImage alloc] init];
	[titleImage loadRawImage:TITLE_IMAGE_FILE withWidth:TITLE_WIDTH height:TITLE_HEIGHT];
	gamePlayViewController = [[Classic_Gold_RunnerViewController alloc] initWithNibName:@"Classic_Gold_RunnerViewController" bundle:nil];
	[window setRootViewController:gamePlayViewController];
	[gamePlayViewController.view removeFromSuperview];
	for (int x=0;x<MAX_MOVE_BLOCKS;x++)
		{
		block_move[x].active = NO;
		block_move[x].mode = 0;
		block_move[x].xblk = 0;
		block_move[x].yblk = 0;
		block_move[x].tile = 0;
		}
    [window addSubview:highScoreScreenController.view];
	[self showHighScores];
    [window makeKeyAndVisible];
	[self startHSTimer];
	[self playSound:SOUND_INTRO];
}

- (id)init
{
	if (!(self = [super init])) return nil;
	customPalette = nil;
	titleImage = nil;
	currentLevel = 1;
	currentBoard = nil;
	currentTileset = nil;
	currentSpriteset = nil;
	staticBackground = nil;
	frame = nil;
	controller_dir = STOP;
	runner = nil;
	guards = [NSMutableArray arrayWithCapacity:MAX_CHARACTERS];
	brd_x_exit = 0;
	brd_y_exit = 0;
	level_gold = 0;
	max_block_move = 0;
	dead = FALSE;
	escapable = FALSE;
	game_mode = 1;
	num_guards = 0;
	score = 0;
	last_score = 1;
	max_block_move = 0;
	runner_dig = NO;
	updateTimer = nil;
	spriteViews = [NSMutableArray arrayWithCapacity:MAX_CHARACTERS];
	gamePlayViewController = nil;
	gameScreenView = nil;
	runner_lives = START_LIVES;
	level = 1;
	leftButtonPressed = NO;
	rightButtonPressed = NO;
	upButtonPressed = NO;
	downButtonPressed = NO;
	highScores = [NSMutableArray arrayWithCapacity:10];
	mostRecentHighScore = 0;
	highScoreEntries = [NSMutableArray arrayWithCapacity:10];
	animationTimer = nil;
	animationFrame = 0;
	HSOverlayView = nil;
	normalHS = nil;
	invertedHS = nil;
	curtainTimer = nil;
	curtainPull = 0;
	background = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background" ofType:@"png"]];
	spotlight = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"spotlight" ofType:@"png"]];
	buttonSize = BUTTON_SIZE_LARGE;
	screenOrientation = SCREEN_ORIENTATION_VERTICAL;
	controlStyle = CONTROL_STYLE_PRECISE;
	defaultStartLevel = 1;
	maxLevel = 1;
	touchStartPosition.x = 0.0;
	touchStartPosition.y = 0.0;
	flickView = nil;
	acceptingInput = YES;
	audioPlayer = nil;
	return self;
}


#pragma mark - Business Logic

- (void)readPreferences
{

	NSFileManager				*fileManager = [NSFileManager defaultManager];
	BOOL						fileExists = NO;
	NSData						*fileData = nil;
	NSDictionary				*prefs = nil;
	NSPropertyListFormat		PListFormat;
	BOOL						fileDeleted = NO;
	NSString					*errorString = nil;

	fileExists = [fileManager fileExistsAtPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/preferences.plist"] isDirectory:NULL];
	if (fileExists == NO)
		{
		// Start level slider could initially be set to values between 0 and 1, causing lockup
		startLevelControl.minimumValue = 1;
		startLevelControl.maximumValue = defaultStartLevel;
		startLevelControl.value = defaultStartLevel;
		[self writePrefsFile];
		}
	else
		{
		fileData = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/preferences.plist"]];
		prefs = [NSPropertyListSerialization propertyListFromData:fileData mutabilityOption:NSPropertyListMutableContainers format:&PListFormat errorDescription:&errorString];
		if ([NSPropertyListSerialization propertyList:prefs isValidForFormat:NSPropertyListXMLFormat_v1_0] == NO)	// The preferences file we read in wasn't valid. Redo the whole thing
			{
			fileDeleted = [fileManager removeItemAtPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/preferences.plist"] error:nil];
			[self writePrefsFile];
			}
		else
			{
			buttonSize = [[prefs objectForKey:@"buttonSize"] intValue];
			buttonSizeControl.selectedSegmentIndex = buttonSize;
			screenOrientation = [[prefs objectForKey:@"screenOrientation"] intValue];
			screenOrientationControl.selectedSegmentIndex = screenOrientation;
			controlStyle = [[prefs objectForKey:@"controlStyle"] intValue];
			controlStyleControl.selectedSegmentIndex = controlStyle;
			defaultStartLevel = [[prefs objectForKey:@"startLevel"] intValue];
			maxLevel = [[prefs objectForKey:@"maxLevel"] intValue];
			startLevelControl.minimumValue = 1;
			startLevelControl.maximumValue = maxLevel;
			startLevelControl.value = defaultStartLevel;
			}
		}
}

- (void)writePrefsFile
{

	NSArray						*dictObjects = nil;
	NSArray						*dictKeys = nil;
	NSDictionary				*prefs = nil;
	NSData						*newFile = nil;
	NSString					*errorString = nil;

	dictObjects = [NSArray arrayWithObjects:[NSNumber numberWithInt:buttonSize], [NSNumber numberWithInt:screenOrientation], [NSNumber numberWithInt:controlStyle], [NSNumber numberWithInt:defaultStartLevel], [NSNumber numberWithInt:maxLevel], nil];
	dictKeys = [NSArray arrayWithObjects:@"buttonSize", @"screenOrientation", @"controlStyle", @"startLevel", @"maxLevel", nil];
	prefs = [NSDictionary dictionaryWithObjects:dictObjects forKeys:dictKeys];
	if ([NSPropertyListSerialization propertyList:prefs isValidForFormat:NSPropertyListXMLFormat_v1_0] == YES)
		{
		newFile = [NSPropertyListSerialization dataFromPropertyList:prefs format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
		if (errorString == nil)
			[newFile writeToFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/preferences.plist"] atomically:NO];
		}
}

- (void)readHighScores
{

	NSFileManager				*fileManager = [NSFileManager defaultManager];
	BOOL						fileExists = NO;
	NSArray						*dictObjects = nil;
	NSArray						*dictKeys = nil;
	NSData						*fileData = nil;
	NSPropertyListFormat		PListFormat;
	BOOL						fileDeleted = NO;
	NSString					*errorString = nil;

	fileExists = [fileManager fileExistsAtPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/highScores.plist"] isDirectory:NULL];
	if (fileExists == NO)
		{
		for (int x=0;x<10;x++)
			{
			dictObjects = [NSArray arrayWithObjects:@"", [NSNumber numberWithInt:0], nil];
			dictKeys = [NSArray arrayWithObjects:@"name", @"score", nil];
			[highScores addObject:[NSDictionary dictionaryWithObjects:dictObjects forKeys:dictKeys]];
			}
		[self writeHSFile];
		}
	else
		{
		fileData = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/highScores.plist"]];
		highScores = [NSPropertyListSerialization propertyListFromData:fileData mutabilityOption:NSPropertyListMutableContainers format:&PListFormat errorDescription:&errorString];
		if ([NSPropertyListSerialization propertyList:highScores isValidForFormat:NSPropertyListXMLFormat_v1_0] == NO)	// The high scores file we read in wasn't valid. Redo the whole thing
			{
			fileDeleted = [fileManager removeItemAtPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/highScores.plist"] error:nil];
			[highScores removeAllObjects];
			for (int x=0;x<10;x++)
				{
				dictObjects = [NSArray arrayWithObjects:@"", [NSNumber numberWithInt:0], nil];
				dictKeys = [NSArray arrayWithObjects:@"name", @"score", nil];
				[highScores addObject:[NSDictionary dictionaryWithObjects:dictObjects forKeys:dictKeys]];
				}
			[self writeHSFile];
			}
		}
}

- (void)writeHSFile
{

	NSData						*newFile = nil;
	NSString					*errorString = nil;

	if ([NSPropertyListSerialization propertyList:highScores isValidForFormat:NSPropertyListXMLFormat_v1_0] == YES)
		{
		newFile = [NSPropertyListSerialization dataFromPropertyList:highScores format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
		if (errorString == nil)
			[newFile writeToFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/highScores.plist"] atomically:NO];
		}
}

- (void)pauseGame
{

	CGSize		backgroundSize;

	backgroundSize.width = HS_VIEW_WIDTH;
	backgroundSize.height = HS_VIEW_HEIGHT;

	// If button is pressed during curtain reveal, abort the reveal
	if (curtainTimer)
		{
		[self finishReveal];
		return;
		}

	if (updateTimer)			// Pausing
		{
		[updateTimer invalidate];
		updateTimer = nil;

		curtainView.hidden = NO;
		curtainView.alpha = 0.75;

		acceptingInput = NO;

		// Paste a darkened image over the gameboard
		UIGraphicsBeginImageContext (backgroundSize);
		[background drawInRect:CGRectMake(0.0, 0.0, HS_VIEW_WIDTH, HS_VIEW_HEIGHT)];
		curtainView.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		}
	else						// Unpausing
		{
		acceptingInput = YES;
		curtainView.hidden = YES;
		curtainView.alpha = 1.0;
		// Now start the level running again
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_LOOP_DELAY target:self selector:@selector(updateFrame:) userInfo:nil repeats:YES];
		}
}

- (void)stopGame
{

	// If button is pressed during curtain reveal, abort the reveal
	if (curtainTimer)
		{
		[self finishReveal];
		return;
		}

	[updateTimer invalidate];
	updateTimer = nil;
	level = defaultStartLevel;
	runner_lives = START_LIVES;
	last_score = 1;
	[guards removeAllObjects];
	for (UIImageView *drawView in spriteViews)
		{
		[drawView removeFromSuperview];
		}
	[spriteViews removeAllObjects];
	currentBoard = nil;
	if (flickView)
		{
		// Remove FlickView from screen before pushing screen off window
		[flickView removeFromSuperview];
		flickView = nil;
		}
	[gamePlayViewController.view removeFromSuperview];
	[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
	[self startHSTimer];

}

- (void)showHighScores
{

	// Set the title image; This may have been released while the game was playing
	NSArray				*fileComponents = [IOG_TITLE_IMAGE_FILE componentsSeparatedByString:@"."];
	HSTitleView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileComponents[0] ofType:fileComponents[1]]];

	// Show the top 10 scores
	for (int index=0;index<10;index++)
		{
		CGRect cellFrame = CGRectMake(0.0, (float)(index * HS_ENTRY_HEIGHT), HS_ENTRY_WIDTH, HS_ENTRY_HEIGHT);
		CGRect rankFrame = CGRectMake(0.0, (HS_ENTRY_HEIGHT - HS_TEXT_HEIGHT) / 2, HS_ENTRY_RANK_WIDTH, HS_TEXT_HEIGHT);
		CGRect scoreFrame = CGRectMake(HS_ENTRY_RANK_WIDTH, (HS_ENTRY_HEIGHT - HS_TEXT_HEIGHT) / 2, HS_ENTRY_SCORE_WIDTH, HS_TEXT_HEIGHT);
		CGRect nameFrame = CGRectMake(HS_ENTRY_RANK_WIDTH + HS_ENTRY_SCORE_WIDTH, (HS_ENTRY_HEIGHT - HS_TEXT_HEIGHT) / 2, HS_ENTRY_NAME_WIDTH, HS_TEXT_HEIGHT);
		UIView *cellContent = [[UIView alloc] initWithFrame:cellFrame];
		UILabel *rankComponent = [[UILabel alloc] initWithFrame:rankFrame];
		UILabel *scoreComponent = [[UILabel alloc] initWithFrame:scoreFrame];
		UILabel *nameComponent = [[UILabel alloc] initWithFrame:nameFrame];
		rankComponent.text = [[NSNumber numberWithInt:(index + 1)] stringValue];
		rankComponent.backgroundColor = [UIColor clearColor];
		rankComponent.textAlignment = UITextAlignmentLeft;
		rankComponent.textColor = [UIColor whiteColor];
		[cellContent addSubview:rankComponent];
		scoreComponent.text = [[[highScores objectAtIndex:index] objectForKey:@"score"] stringValue];
		scoreComponent.backgroundColor = [UIColor clearColor];
		scoreComponent.textAlignment = UITextAlignmentLeft;
		scoreComponent.textColor = [UIColor whiteColor];
		[cellContent addSubview:scoreComponent];
		nameComponent.text = [[highScores objectAtIndex:index] objectForKey:@"name"];
		nameComponent.backgroundColor = [UIColor clearColor];
		nameComponent.textAlignment = UITextAlignmentLeft;
		nameComponent.textColor = [UIColor whiteColor];
		[cellContent addSubview:nameComponent];
		[HSList addSubview:cellContent];
		[highScoreEntries addObject:cellContent];
		}

	// Set up high score animation
	[self setupHighScoreAnimation];

}

- (void)setupHighScoreAnimation
{

	CGRect					cellFrame = CGRectMake(0.0, 0.0, HS_ENTRY_WIDTH, HS_ENTRY_HEIGHT);
	CGRect					rankFrame = CGRectMake(0.0, (HS_ENTRY_HEIGHT - HS_TEXT_HEIGHT) / 2, HS_ENTRY_RANK_WIDTH, HS_TEXT_HEIGHT);
	CGRect					scoreFrame = CGRectMake(HS_ENTRY_RANK_WIDTH, (HS_ENTRY_HEIGHT - HS_TEXT_HEIGHT) / 2, HS_ENTRY_SCORE_WIDTH, HS_TEXT_HEIGHT);
	CGRect					nameFrame = CGRectMake(HS_ENTRY_RANK_WIDTH + HS_ENTRY_SCORE_WIDTH, (HS_ENTRY_HEIGHT - HS_TEXT_HEIGHT) / 2, HS_ENTRY_NAME_WIDTH, HS_TEXT_HEIGHT);
	UILabel					*rankComponent = nil;
	UILabel					*scoreComponent = nil;
	UILabel					*nameComponent = nil;

	if (normalHS)
		{
		[normalHS removeFromSuperview];
		normalHS = nil;
		[invertedHS removeFromSuperview];
		invertedHS = nil;
		}

	HSOverlayView.frame = CGRectMake(0.0, (HS_ENTRY_HEIGHT * mostRecentHighScore), HS_ENTRY_WIDTH, HS_ENTRY_HEIGHT);

	normalHS = [[UIView alloc] initWithFrame:cellFrame];
	normalHS.clipsToBounds = YES;
	rankComponent = [[UILabel alloc] initWithFrame:rankFrame];
	scoreComponent = [[UILabel alloc] initWithFrame:scoreFrame];
	nameComponent = [[UILabel alloc] initWithFrame:nameFrame];
	rankComponent.text = [[NSNumber numberWithInt:(mostRecentHighScore + 1)] stringValue];
	rankComponent.textAlignment = UITextAlignmentLeft;
	rankComponent.backgroundColor = [UIColor blackColor];
	rankComponent.textColor = [UIColor whiteColor];
	[normalHS addSubview:rankComponent];
	scoreComponent.text = [[[highScores objectAtIndex:mostRecentHighScore] objectForKey:@"score"] stringValue];
	scoreComponent.textAlignment = UITextAlignmentLeft;
	scoreComponent.backgroundColor = [UIColor blackColor];
	scoreComponent.textColor = [UIColor whiteColor];
	[normalHS addSubview:scoreComponent];
	nameComponent.text = [[highScores objectAtIndex:mostRecentHighScore] objectForKey:@"name"];
	nameComponent.textAlignment = UITextAlignmentLeft;
	nameComponent.backgroundColor = [UIColor blackColor];
	nameComponent.textColor = [UIColor whiteColor];
	[normalHS addSubview:nameComponent];

	invertedHS = [[UIView alloc] initWithFrame:cellFrame];
	invertedHS.clipsToBounds = YES;
	rankComponent = [[UILabel alloc] initWithFrame:rankFrame];
	scoreComponent = [[UILabel alloc] initWithFrame:scoreFrame];
	nameComponent = [[UILabel alloc] initWithFrame:nameFrame];
	rankComponent.text = [[NSNumber numberWithInt:(mostRecentHighScore + 1)] stringValue];
	rankComponent.textAlignment = UITextAlignmentLeft;
	rankComponent.backgroundColor = [UIColor whiteColor];
	rankComponent.textColor = [UIColor blackColor];
	[invertedHS addSubview:rankComponent];
	scoreComponent.text = [[[highScores objectAtIndex:mostRecentHighScore] objectForKey:@"score"] stringValue];
	scoreComponent.textAlignment = UITextAlignmentLeft;
	scoreComponent.backgroundColor = [UIColor whiteColor];
	scoreComponent.textColor = [UIColor blackColor];
	[invertedHS addSubview:scoreComponent];
	nameComponent.text = [[highScores objectAtIndex:mostRecentHighScore] objectForKey:@"name"];
	nameComponent.textAlignment = UITextAlignmentLeft;
	nameComponent.backgroundColor = [UIColor whiteColor];
	nameComponent.textColor = [UIColor blackColor];
	[invertedHS addSubview:nameComponent];

	// Add both subviews to the overlay view. We'll "animate" by adjusting the frames and which view is on top. Start with inverted view on top
	[HSOverlayView addSubview:invertedHS];
	[HSOverlayView addSubview:normalHS];
}

- (void)updateHSAnimation:(NSTimer *)timer;
{

	// Figure out which "frame" to display next
	if (animationFrame < ((HS_ENTRY_HEIGHT * 2) - 1))
		{
		animationFrame++;
		}
	else
		{
		animationFrame = 0;
		}
	// Swap the foreground view when necessary
	if (animationFrame == 1)
		{
		[HSOverlayView bringSubviewToFront:normalHS];
		invertedHS.frame = CGRectMake(0.0, 0.0, HS_ENTRY_WIDTH, HS_ENTRY_HEIGHT);
		}
	else if (animationFrame == (HS_ENTRY_HEIGHT + 1))
		{
		normalHS.frame = CGRectMake(0.0, 0.0, HS_ENTRY_WIDTH, HS_ENTRY_HEIGHT);
		[HSOverlayView bringSubviewToFront:invertedHS];
		}
	// Now piece together the 2 views that will simulate the animation
	if (animationFrame == 0)						// The original, unhighlighted image
		{
		normalHS.frame = CGRectMake(0.0, 0.0, HS_ENTRY_WIDTH, HS_ENTRY_HEIGHT);
		}
	else if (animationFrame == HS_ENTRY_HEIGHT)		// The full inverted view
		{
		invertedHS.frame = CGRectMake(0.0, 0.0, HS_ENTRY_WIDTH, HS_ENTRY_HEIGHT);
		}
	else if (animationFrame < HS_ENTRY_HEIGHT)		// Inverted image gets placed first
		{
		normalHS.frame = CGRectMake(0.0, 0.0, HS_ENTRY_WIDTH, HS_ENTRY_HEIGHT - animationFrame);
		}
	else											// Original image gets placed first
		{
		invertedHS.frame = CGRectMake(0.0, 0.0, HS_ENTRY_WIDTH, HS_ENTRY_HEIGHT - (animationFrame - HS_ENTRY_HEIGHT));
		}
}

- (void)startHSTimer;
{

	animationFrame = 1;
	[HSOverlayView bringSubviewToFront:normalHS];
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:ANIMATION_LOOP_DELAY target:self selector:@selector(updateHSAnimation:) userInfo:nil repeats:YES];
}

- (void)stopHSTimer;
{
	[animationTimer invalidate];
	animationTimer = nil;
}

- (IBAction)showPreferences:(id)sender
{

	[self stopHSTimer];
    [window addSubview:preferencesScreenController.view];
}

- (IBAction)showInstructions:(id)sender
{

	[self stopHSTimer];
    [window addSubview:instructionsScreenController.view];
}

- (IBAction)setStartLevel:(id)sender
{

	[self stopHSTimer];
	startLevelDisplay.text = [[NSNumber numberWithFloat:startLevelControl.value] stringValue];
    [window addSubview:startLevelScreenController.view];
}

- (IBAction)startGame:(id)sender
{

	// First, load up the gameboard we need
	if (level != defaultStartLevel || currentBoard == nil)		// The requested board isn't already loaded, get it
		{
		level = defaultStartLevel;
		currentBoard = [[Gameboard alloc] init];
		if ([currentBoard loadGameboard:level] == NO)
			{
			}
		}
	// If the tile and sprite files are the same, don't reload, reuse!
	if ([currentBoard.tileFilename isEqualToString:currentTileset.filename] == NO || currentTileset == nil)
		{
		currentTileset = [[ImageSet alloc] init];
		if ([currentTileset loadImages:currentBoard.tileFilename mode:0] == NO)
			{
			}
		else
			{
			currentTileset.filename = currentBoard.tileFilename;
			self.currentTileFilename = currentBoard.tileFilename;
			}
		}
	if ([currentBoard.spriteFilename isEqualToString:currentSpriteset.filename] == NO || currentSpriteset == nil)
		{
		currentSpriteset = [[ImageSet alloc] init];
		if ([currentSpriteset loadImages:currentBoard.spriteFilename mode:1] == NO)
			{
			}
		else
			{
			currentSpriteset.filename = currentBoard.spriteFilename;
			self.currentSpriteFilename = currentBoard.spriteFilename;
			}
		}
	[self stopHSTimer];
	// Set up all necessary info to start the first level
	[self loadBackgroundImage];
	// Set the frame to the screen and add image views for the characters
	if (screenOrientation == SCREEN_ORIENTATION_VERTICAL)
		{
		[gamePlayViewController setViewType:buttonSize];
		[window addSubview:gamePlayViewController.view];
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
		}
	else
		{
		UIScreen *screen = [UIScreen mainScreen];
		[gamePlayViewController setViewType:BUTTON_SIZE_HORIZONTAL];
		[window addSubview:gamePlayViewController.view];
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
		[gamePlayViewController.view setTransform:CGAffineTransformMakeRotation(90 * 3.14 / 180)];
		gamePlayViewController.view.bounds = CGRectMake(0, 0, screen.bounds.size.height, screen.bounds.size.width);
		gamePlayViewController.view.center = CGPointMake( screen.bounds.size.width/2, screen.bounds.size.height/2 );
		}
	self.gameScreenView = gamePlayViewController.gameView;
	gameScreenView.hidden = YES;					// Done to keep the level from flashing before the curtain reveal
	gameScreenView.image = frame;					// Always autorelease frame when it gets assigned to the imageview
	curtainView = gamePlayViewController.curtain;
	[self loadLevelStats];
	// Add the subview that draw the characters
	for (UIImageView *drawView in spriteViews)
		{
		[gameScreenView addSubview:drawView];
		}
	last_score = 1;
	score = 0;
	[self Start_Level];
	[self startReveal];
}

- (IBAction)acceptHighScore:(id)sender
{

	int							index = 9;
	NSArray						*dictObjects = nil;
	NSArray						*dictKeys = nil;

	// First, find where in the high scores list this entry belongs
	do
		{
		index--;
		}
	while (index >= 0 && (score > [[[highScores objectAtIndex:index] objectForKey:@"score"] intValue]));
	index++;
	mostRecentHighScore = index;
	// Then, insert the new entry, pushing the rest down
	dictObjects = [NSArray arrayWithObjects:highScoreName.text, [NSNumber numberWithInt:score], nil];
	dictKeys = [NSArray arrayWithObjects:@"name", @"score", nil];
	[highScores insertObject:[NSDictionary dictionaryWithObjects:dictObjects forKeys:dictKeys] atIndex:index];
	[highScores removeObjectAtIndex:10];
	score = 0;						// Need to do this here to prevent resetting score before high score is saved
	[self writeHSFile];
	// Finally, rebuild the visual display
	while (index < 10)
		{
		CGRect cellFrame = CGRectMake(0.0, (float)(index * HS_ENTRY_HEIGHT), HS_ENTRY_WIDTH, HS_ENTRY_HEIGHT);
		CGRect rankFrame = CGRectMake(0.0, (HS_ENTRY_HEIGHT - HS_TEXT_HEIGHT) / 2, HS_ENTRY_RANK_WIDTH, HS_TEXT_HEIGHT);
		CGRect scoreFrame = CGRectMake(HS_ENTRY_RANK_WIDTH, (HS_ENTRY_HEIGHT - HS_TEXT_HEIGHT) / 2, HS_ENTRY_SCORE_WIDTH, HS_TEXT_HEIGHT);
		CGRect nameFrame = CGRectMake(HS_ENTRY_RANK_WIDTH + HS_ENTRY_SCORE_WIDTH, (HS_ENTRY_HEIGHT - HS_TEXT_HEIGHT) / 2, HS_ENTRY_NAME_WIDTH, HS_TEXT_HEIGHT);
		UIView *cellContent = [[UIView alloc] initWithFrame:cellFrame];
		UILabel *rankComponent = [[UILabel alloc] initWithFrame:rankFrame];
		UILabel *scoreComponent = [[UILabel alloc] initWithFrame:scoreFrame];
		UILabel *nameComponent = [[UILabel alloc] initWithFrame:nameFrame];
		rankComponent.text = [[NSNumber numberWithInt:(index + 1)] stringValue];
		rankComponent.backgroundColor = [UIColor clearColor];
		rankComponent.textAlignment = UITextAlignmentLeft;
		rankComponent.textColor = [UIColor whiteColor];
		[cellContent addSubview:rankComponent];
		scoreComponent.text = [[[highScores objectAtIndex:index] objectForKey:@"score"] stringValue];
		scoreComponent.backgroundColor = [UIColor clearColor];
		scoreComponent.textAlignment = UITextAlignmentLeft;
		scoreComponent.textColor = [UIColor whiteColor];
		[cellContent addSubview:scoreComponent];
		nameComponent.text = [[highScores objectAtIndex:index] objectForKey:@"name"];
		nameComponent.backgroundColor = [UIColor clearColor];
		nameComponent.textAlignment = UITextAlignmentLeft;
		nameComponent.textColor = [UIColor whiteColor];
		[cellContent addSubview:nameComponent];
		// Get the old high score entry view outta there
		[[highScoreEntries objectAtIndex:index] removeFromSuperview];
		[HSList addSubview:cellContent];
		[highScoreEntries replaceObjectAtIndex:index withObject:cellContent];
		index++;
		}
	[enterHSView removeFromSuperview];

	// Now set up to start the high score animation on a new score slot
	[self setupHighScoreAnimation];
	[self startHSTimer];
}

- (IBAction)cancelHighScore:(id)sender
{

	score = 0;						// Need to do this here to prevent resetting score before high score is saved
	mostRecentHighScore = 0;		// Default to highlighting highest score
	[enterHSView removeFromSuperview];
	[self setupHighScoreAnimation];
	[self startHSTimer];
}

- (IBAction)closePreferences:(id)sender
{

	buttonSize = buttonSizeControl.selectedSegmentIndex;
	screenOrientation = screenOrientationControl.selectedSegmentIndex;
	controlStyle = controlStyleControl.selectedSegmentIndex;

	[self writePrefsFile];

	[preferencesScreenController.view removeFromSuperview];
	[self startHSTimer];

}

- (IBAction)closeInstructions:(id)sender
{
	[instructionsScreenController.view removeFromSuperview];
}

- (IBAction)closeSetStartLevel:(id)sender
{

	defaultStartLevel = startLevelControl.value;

	[self writePrefsFile];

	[startLevelScreenController.view removeFromSuperview];
	[self startHSTimer];

}

- (void)startReveal
{

	CGSize		backgroundSize;
	UIImage		*tempImage = nil;

	backgroundSize.width = HS_VIEW_WIDTH * 2;
	backgroundSize.height = HS_VIEW_HEIGHT * 2;

	// Clear out any residual image
	UIGraphicsBeginImageContext (backgroundSize);
	[background drawInRect:CGRectMake(0.0, 0.0, HS_VIEW_WIDTH * 2, HS_VIEW_HEIGHT * 2)];
	tempImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	curtainView.image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([tempImage CGImage], CGRectMake((HS_VIEW_WIDTH / 2), (HS_VIEW_HEIGHT / 2), HS_VIEW_WIDTH, HS_VIEW_HEIGHT))];

	// Set up flick view to dismiss curtain on any touch
	if (flickView == nil)
		{
		if (screenOrientation == SCREEN_ORIENTATION_HORIZONTAL)
			{
			flickView = [[FlickView alloc] initWithFrame:CGRectMake(0.0, 0.0, gamePlayViewController.view.frame.size.height, gamePlayViewController.view.frame.size.width)];
			}
		else
			{
			flickView = [[FlickView alloc] initWithFrame:CGRectMake(0.0, 0.0, gamePlayViewController.view.frame.size.width, gamePlayViewController.view.frame.size.height)];
			}
		[gamePlayViewController.view addSubview:flickView];
		if (screenOrientation == SCREEN_ORIENTATION_HORIZONTAL)
			{
			UIScreen *screen = [UIScreen mainScreen];
			[flickView setTransform:CGAffineTransformMakeRotation(90 * 3.14 / 180)];
			flickView.bounds = CGRectMake(0, 0, screen.bounds.size.height, screen.bounds.size.width);
			flickView.center = CGPointMake( screen.bounds.size.width/2, screen.bounds.size.height/2 );
			}
		[gamePlayViewController.view bringSubviewToFront:gamePlayViewController.pauseButton];
		[gamePlayViewController.view bringSubviewToFront:gamePlayViewController.quitButton];
		}

	if (screenOrientation != SCREEN_ORIENTATION_HORIZONTAL)
		{
		curtainPull = 0;
		curtainView.hidden = NO;
		curtainTimer = [NSTimer scheduledTimerWithTimeInterval:CURTAIN_LOOP_DELAY target:self selector:@selector(revealCurtain:) userInfo:nil repeats:YES];
		}
	else						// When in horizontal mode we skip the curtain reveal because I didn't feel like fixing the reveal code to deal with the bigger view
		{
		curtainView.hidden = YES;
		gameScreenView.hidden = NO;
		[runner setDir:STOP];
		[self setController_dir:STOP];
		[self setRunner_dig:FALSE];
		// Now start the level running
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_LOOP_DELAY target:self selector:@selector(updateFrame:) userInfo:nil repeats:YES];
		}

}

- (void)revealCurtain:(NSTimer *)timer
{

	UIImage		*tempImage = nil;
	CGSize		backgroundSize;
	float		startx = 0.0;
	float		starty = 0.0;
	float		drawx = 0.0;
	float		drawy = 0.0;
	float		sizex = 0.0;
	float		sizey = 0.0;
	float		drawoffsetx = 0.0;
	float		drawoffsety = 0.0;

	startx = ((HS_VIEW_WIDTH - SPOTLIGHT_START_WIDTH) / 2) - (SPOTLIGHT_STEP_X * curtainPull);
	starty = ((HS_VIEW_HEIGHT - SPOTLIGHT_START_HEIGHT) / 2) - (SPOTLIGHT_STEP_Y * curtainPull);
	sizex = (SPOTLIGHT_START_WIDTH + (SPOTLIGHT_STEP_X * 2 * curtainPull));
	sizey = (SPOTLIGHT_START_HEIGHT + (SPOTLIGHT_STEP_Y * 2 * curtainPull));

	if (startx >= 0)
		{
		drawx = (HS_VIEW_WIDTH / 2) + startx;
		}
	else
		{
		drawoffsetx = abs(sizex);
		startx = 0;
		sizex = HS_VIEW_WIDTH;
		drawx = HS_VIEW_WIDTH / 2;
		}
	if (starty >= 0)
		{
		drawy = (HS_VIEW_HEIGHT / 2) + starty;
		}
	else
		{
		drawoffsety = abs(sizey);
		starty = 0;
		sizey = HS_VIEW_HEIGHT;
		drawy = HS_VIEW_HEIGHT / 2;
		}
	backgroundSize.width = HS_VIEW_WIDTH * 2;
	backgroundSize.height = HS_VIEW_HEIGHT * 2;

	UIGraphicsBeginImageContext (backgroundSize);
	// First, draw black background
	[background drawInRect:CGRectMake(0.0, 0.0, HS_VIEW_WIDTH * 2, HS_VIEW_HEIGHT * 2)];
	// Next, draw just a piece of the gameboard
	[[UIImage imageWithCGImage:CGImageCreateWithImageInRect([gameScreenView.image CGImage], CGRectMake(startx, starty, sizex, sizey))] drawAtPoint:CGPointMake(drawx, drawy)];
	// Finally, draw transparent ellipse
	[spotlight drawInRect:CGRectMake(drawx - drawoffsetx, drawy - drawoffsety, sizex + (drawoffsetx * 2), sizey + (drawoffsety * 2))];
	tempImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	curtainView.image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([tempImage CGImage], CGRectMake((HS_VIEW_WIDTH / 2), (HS_VIEW_HEIGHT / 2), HS_VIEW_WIDTH, HS_VIEW_HEIGHT))];

	curtainPull++;
	if (((sizex + (drawoffsetx * 2)) > (HS_VIEW_WIDTH * 2)) && ((sizey + (drawoffsety * 2)) > (HS_VIEW_HEIGHT * 2)))
		{
		[self finishReveal];
		}

}

- (void)finishReveal
{

	[curtainTimer invalidate];
	curtainTimer = nil;

	curtainView.hidden = YES;
	gameScreenView.hidden = NO;

	if (controlStyle != CONTROL_STYLE_FLICK)
		{
		// Remove FlickView from screen before setting up a new one
		[flickView removeFromSuperview];
		flickView = nil;
		}

	[runner setDir:STOP];
	[self setController_dir:STOP];
	[self setRunner_dig:FALSE];

	// Now start the level running
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_LOOP_DELAY target:self selector:@selector(updateFrame:) userInfo:nil repeats:YES];

}

- (void)Start_Level
{

   short x, y;

	// Close any holes that were in the process of being dug when the player died
   for (x=0;x<MAX_OBJECTS;x++)
      {
      if (objs[x].active && (objs[x].type == OBJECT_TYPE_HOLE))
         {
         objs[x].state = 9;
         objs[x].time = DISINTEGRATION_RATE;
         }
      }
   [self Process_Objects];

   for (Character *guard in guards)
      {
      [guard decrementGold];
      [guard setFall:0];
      [guard setTime:0];
      }

   if (escapable)
      [self Remove_Escape];

   for (y=0;y<BOARD_MAXHEIGHT;y++)
	  {
      for (x=0;x<BOARD_MAXLENGTH;x++)
         {
         if ([currentBoard attachmentForRow:y column:x])
            {
			[currentBoard setAttachment:0 forRow:y column:x];
            block_move[max_block_move].active = YES;
            block_move[max_block_move].mode = 0;
            block_move[max_block_move].xblk = x;
            block_move[max_block_move].yblk = y;
            block_move[max_block_move++].tile = (short)[currentBoard tileForRow:y column:x];
            }
         }
	 }

   for (x=0;x<level_gold;x++)
      {
	  [currentBoard setAttachment:gold_start[x].tile forRow:gold_start[x].yblk column:gold_start[x].xblk];
      block_move[max_block_move].active = YES;
      block_move[max_block_move].mode = 1;
      block_move[max_block_move].xblk = gold_start[x].xblk;
      block_move[max_block_move].yblk = gold_start[x].yblk;
      block_move[max_block_move++].tile = gold_start[x].tile;
      }

   game_mode = 2;

	[runner setXPos:(player[0].xblk * [currentBoard tileWidth])];
	[runner setYPos:(player[0].yblk * [currentBoard tileHeight])];
	[runner setXBlk:player[0].xblk];
	[runner setYBlk:player[0].yblk];
	[runner setSprite:player[0].sprite];
	[runner setMove:TRUE];
	for (Character *guard in guards)
		{
		[guard setXPos:(player[([guards indexOfObject:guard] + 1)].xblk * [currentBoard tileWidth])];
		[guard setYPos:(player[([guards indexOfObject:guard] + 1)].yblk * [currentBoard tileHeight])];
		[guard setXBlk:player[([guards indexOfObject:guard] + 1)].xblk];
		[guard setYBlk:player[([guards indexOfObject:guard] + 1)].yblk];
		[guard setSprite:player[([guards indexOfObject:guard] + 1)].sprite];
		[guard setMove:TRUE];
		if (player[([guards indexOfObject:guard] + 1)].sprite >= GUARD_LEFT_START && player[([guards indexOfObject:guard] + 1)].sprite <= GUARD_LEFT_END)
			[guard setDir:LEFT];
		else if (player[([guards indexOfObject:guard] + 1)].sprite >= GUARD_RIGHT_START && player[([guards indexOfObject:guard] + 1)].sprite <= GUARD_RIGHT_END)
			[guard setDir:RIGHT];
		else if (player[([guards indexOfObject:guard] + 1)].sprite >= GUARD_CLIMB_START && player[([guards indexOfObject:guard] + 1)].sprite <= GUARD_CLIMB_END)
			[guard setDir:DOWN];
		}
	[runner setDir:STOP];
	[self setController_dir:STOP];
	[self setRunner_dig:FALSE];
	dead = NO;
	leftButtonPressed = NO;
	rightButtonPressed = NO;
	upButtonPressed = NO;
	downButtonPressed = NO;
	acceptingInput = YES;

}

- (void)updateFrame:(NSTimer *)timer
{

	for (Character *guard in guards)
		{
		[guard Chase_Pattern];
		}
	/* Set_Block - update any blocks that have changed */
	[self Process_Objects];
	for (Character *guard in guards)
		{
		[guard Character_Placement];
		}
	[runner Character_Placement];
	[self Collision_Detection];
	[gamePlayViewController setStats:score level:level lives:runner_lives];
	if (dead)
		{
		[self Runner_Die];
		if (game_mode == 3)
			{
			level = defaultStartLevel;
			runner_lives = START_LIVES;
			last_score = 1;
			[guards removeAllObjects];
			for (UIImageView *drawView in spriteViews)
				{
				[drawView removeFromSuperview];
				}
			[spriteViews removeAllObjects];
			currentBoard = nil;
			if (flickView)
				{
				// Remove FlickView from screen before pushing screen off window
				[flickView removeFromSuperview];
				flickView = nil;
				}
			[gamePlayViewController.view removeFromSuperview];
			[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
			if (score > [[[highScores objectAtIndex:9] objectForKey:@"score"] intValue])		// Only need to check against the lowest high score
				{
				[self playSound:SOUND_SCORE];
				[self Enter_High_Score];
				}
			else
				{
				[self startHSTimer];
				}
			}
		else if (game_mode == 2)
			{
			[self Start_Level];
			// Now start the level running
			updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_LOOP_DELAY target:self selector:@selector(updateFrame:) userInfo:nil repeats:YES];
			}
		}
	else
		{
		if (game_mode == 1)			// Board was just won, load next board
			{
			// Clear out everything from the last level
			[guards removeAllObjects];
			for (UIImageView *drawView in spriteViews)
				{
				[drawView removeFromSuperview];
				}
			[spriteViews removeAllObjects];
			// Set up all necessary info to start the next level
			currentBoard = [[Gameboard alloc] init];
			if ([currentBoard loadGameboard:level] == NO)
				{
				}
			[self loadBackgroundImage];
			gameScreenView.image = frame;		// Always autorelease frame when it gets assigned to the imageview
			[self loadLevelStats];
			// Add the subview that draw the characters
			for (UIImageView *drawView in spriteViews)
				{
				[gameScreenView addSubview:drawView];
				}
			[self Start_Level];
			[self startReveal];
			}
		else
			{
			[self Update_Display];
			}
		}
}

- (void)Update_Display
{

	if (max_block_move)
		{
		// Re-create code from loadBackgroundImage, sometimes setting a tile from the sprite graphics set
		CGSize		backgroundSize;
		CGPoint		drawPoint;

		backgroundSize.width = [currentBoard boardWidth] * [currentBoard tileWidth];
		backgroundSize.height = [currentBoard boardHeight] * [currentBoard tileHeight];
		UIGraphicsBeginImageContext (backgroundSize);
		[frame drawAtPoint:CGPointMake(0,0)];		// Start with the background as it already exists
		for (int x=0;x<max_block_move;x++)
			{
			if (block_move[x].active == YES)
				{
				drawPoint.x = block_move[x].xblk * [currentBoard tileWidth];
				drawPoint.y = block_move[x].yblk * [currentBoard tileHeight];
				if (block_move[x].mode == 0)
					[[currentTileset imageForSlot:(int)block_move[x].tile] drawAtPoint:drawPoint];
				else
					[[currentSpriteset imageForSlot:(int)block_move[x].tile] drawAtPoint:drawPoint];
				block_move[x].active = NO;
				}
			}
		// Retain this object when you create it, and autorelease it when you assign it to an imageview
		frame = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		max_block_move = 0;
		gameScreenView.image = frame;		// Always autorelease frame when it gets assigned to the imageview
		}
	[self Draw_Characters];
	last_score = score;
}

- (void)Draw_Characters
{

	CGRect					viewFrame;
	UIImageView				*drawView = nil;

	// Draw the runner
	if (screenOrientation == SCREEN_ORIENTATION_HORIZONTAL)
		{
		CGSize frameSize = [[currentSpriteset imageForSlot:[runner sprite]] size];
		viewFrame.origin.x = [runner xpos] * HORIZONTAL_VIEW_X_MULT_FACTOR;
		viewFrame.origin.y = [runner ypos] * HORIZONTAL_VIEW_Y_MULT_FACTOR;
		viewFrame.size.width = frameSize.width * HORIZONTAL_VIEW_X_MULT_FACTOR;
		viewFrame.size.height = frameSize.height * HORIZONTAL_VIEW_Y_MULT_FACTOR;
		}
	else
		{
		viewFrame.origin.x = [runner xpos];
		viewFrame.origin.y = [runner ypos];
		viewFrame.size = [[currentSpriteset imageForSlot:[runner sprite]] size];
		}
	drawView = [spriteViews objectAtIndex:0];
	drawView.frame = viewFrame;
	drawView.image = [currentSpriteset imageForSlot:[runner sprite]];
	// Draw the guards
	for (Character *guard in guards)
		{
		if (screenOrientation == SCREEN_ORIENTATION_HORIZONTAL)
			{
			CGSize frameSize = [[currentSpriteset imageForSlot:[guard sprite]] size];
			viewFrame.origin.x = [guard xpos] * HORIZONTAL_VIEW_X_MULT_FACTOR;
			viewFrame.origin.y = [guard ypos] * HORIZONTAL_VIEW_Y_MULT_FACTOR;
			viewFrame.size.width = frameSize.width * HORIZONTAL_VIEW_X_MULT_FACTOR;
			viewFrame.size.height = frameSize.height * HORIZONTAL_VIEW_Y_MULT_FACTOR;
			}
		else
			{
			viewFrame.origin.x = [guard xpos];
			viewFrame.origin.y = [guard ypos];
			viewFrame.size = [[currentSpriteset imageForSlot:[guard sprite]] size];
			}
		drawView = [spriteViews objectAtIndex:([guards indexOfObject:guard] + 1)];		// Index 0 is the runner
		drawView.frame = viewFrame;
		drawView.image = [currentSpriteset imageForSlot:[guard sprite]];
		}
}

- (void)playSound:(int)soundNum
{


	switch (soundNum)
		{
		case SOUND_INTRO:
			audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Intro" ofType:@"aif"]] error:nil];
			break;
		case SOUND_PLGETGLD:
			audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"PlayerGetGold" ofType:@"aif"]] error:nil];
			break;
		case SOUND_GDGETGLD:
			audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"GuardGetGold" ofType:@"aif"]] error:nil];
			break;
		case SOUND_DIG:
			audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Dig" ofType:@"aif"]] error:nil];
			break;
		case SOUND_DIE:
			audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"GuardDie" ofType:@"aif"]] error:nil];
			break;
		case SOUND_WIN:
			audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"WinLevel" ofType:@"aif"]] error:nil];
			break;
		case SOUND_SCORE:
			audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"HighScore" ofType:@"aif"]] error:nil];
			break;
		default:
			break;
		}

	[audioPlayer setDelegate:self];
	[audioPlayer play];

}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
}

- (void)loadBackgroundImage
{

	CGSize					backgroundSize;
	CGPoint					drawPoint;

	backgroundSize.width = [currentBoard boardWidth] * [currentBoard tileWidth];
	backgroundSize.height = [currentBoard boardHeight] * [currentBoard tileHeight];
	UIGraphicsBeginImageContext (backgroundSize);

	for (int rowIndex=0;rowIndex<[currentBoard boardHeight];rowIndex++)
		{
		for (int columnIndex=0;columnIndex<[currentBoard boardWidth];columnIndex++)
			{
			drawPoint.x = columnIndex * [currentBoard tileWidth];
			drawPoint.y = rowIndex * [currentBoard tileHeight];
			[[currentTileset imageForSlot:(int)[currentBoard tileForRow:rowIndex column:columnIndex]] drawAtPoint:drawPoint];
			}
		}
	// Retain this object when you create it, and autorelease it when you assign it to an imageview
	frame = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

}

/* Pull information from the gameboard, including player start locaton, guard start locations, gold start locations and escape ladder location */
- (void)loadLevelStats
{

	num_guards = 0;
	level_gold = 0;

	 for (int y=0;y<[currentBoard boardHeight];y++)
		{
		for (int x=0;x<[currentBoard boardWidth];x++)
		   {
		   if ([currentBoard attachmentForRow:y column:x])
			  {
			  if ([currentBoard attachmentForRow:y column:x] == GOLD_TILE_GRND || [currentBoard attachmentForRow:y column:x] == GOLD_TILE_SKY)
				 {
				 gold_start[level_gold].xblk = x;
				 gold_start[level_gold].yblk = y;
				 gold_start[level_gold++].tile = [currentBoard attachmentForRow:y column:x];
				 }
			  else if ((([currentBoard attachmentForRow:y column:x] >= GUARD_LEFT_START && [currentBoard attachmentForRow:y column:x] <= GUARD_LEFT_END) || ([currentBoard attachmentForRow:y column:x] >= GUARD_RIGHT_START && [currentBoard attachmentForRow:y column:x] <= GUARD_RIGHT_END) || ([currentBoard attachmentForRow:y column:x] >= GUARD_CLIMB_START && [currentBoard attachmentForRow:y column:x] <= GUARD_CLIMB_END)) && num_guards < (MAX_CHARACTERS - 1))
				 {
				 player[++num_guards].xblk = x;
				 player[num_guards].yblk = y;
				 player[num_guards].sprite = [currentBoard attachmentForRow:y column:x];
				 }
			  else if (([currentBoard attachmentForRow:y column:x] >= RUNNER_LEFT_START && [currentBoard attachmentForRow:y column:x] <= RUNNER_LEFT_END) || ([currentBoard attachmentForRow:y column:x] >= RUNNER_RIGHT_START && [currentBoard attachmentForRow:y column:x] <= RUNNER_RIGHT_END))
				 {
				 player[0].xblk = x;
				 player[0].yblk = y;
				 player[0].sprite = [currentBoard attachmentForRow:y column:x];
				 }
			  else if ([currentBoard attachmentForRow:y column:x] == ESCAPE_LADDER)
				 {
				 brd_x_exit = x;
				 brd_y_exit = y;
				 }
			  }
		   }
		}
	// Seems this would be a good place to create the character objects
	runner = [[Character alloc] init];
	[runner setAsRunner];
	// Set up a UIImageView for the sprite for this character
	UIImageView *spriteView = [[UIImageView alloc] init];
	[spriteViews addObject:spriteView];
	for (int x=0;x<num_guards;x++)
		{
		Character *newCharacter = [[Character alloc] init];
		UIImageView *spriteView = [[UIImageView alloc] init];
		[guards addObject:newCharacter];
		// Set up a UIImageView for the sprite for this character
		[spriteViews addObject:spriteView];
		}

}

- (void)Process_Objects
{

   int x, done;

   for (x=0;x<MAX_OBJECTS;x++)
      {
      if (objs[x].active)
         {
         done = FALSE;
         switch (objs[x].type)
            {
            case OBJECT_TYPE_HOLE:						/* Dug Blocks */
               switch (objs[x].state)
                  {
                  case 1:
                     for (Character *guard in guards)
                        {
                        if ([guard xblk] == objs[x].xblk && [guard yblk] + 1 == objs[x].yblk)
                           {
                           objs[x].state = 9;
                           objs[x].time = DISINTEGRATION_RATE;
                           [runner setTime:0];
                           done = TRUE;
                           }
                        }
                     if (!done && objs[x].time == DISINTEGRATION_RATE)
                        {
                        objs[x].state = 2;
                        objs[x].time = 0;
                        objs[x].sprite++;
                        block_move[max_block_move].active = YES;
                        block_move[max_block_move].mode = 0;
                        block_move[max_block_move].xblk = objs[x].xblk;
                        block_move[max_block_move].yblk = objs[x].yblk;
                        block_move[max_block_move].tile = objs[x].sprite;
						[currentBoard setTile: block_move[max_block_move].tile forRow:block_move[max_block_move].yblk column:block_move[max_block_move].xblk];
						max_block_move++;
                        }
                     else if (!done)
                        objs[x].time++;
                     break;
                  case 2:
                     for (Character *guard in guards)
                        {
                        if ([guard xblk] == objs[x].xblk && [guard yblk] + 1 == objs[x].yblk)
                           {
                           objs[x].state = 9;
                           objs[x].time = DISINTEGRATION_RATE;
                           [runner setTime:0];
                           done = TRUE;
                           }
                        }
                     if (!done && objs[x].time == DISINTEGRATION_RATE)
                        {
                        objs[x].state = 3;
                        objs[x].time = 0;
                        objs[x].sprite++;
                        block_move[max_block_move].active = YES;
                        block_move[max_block_move].mode = 0;
                        block_move[max_block_move].xblk = objs[x].xblk;
                        block_move[max_block_move].yblk = objs[x].yblk;
                        block_move[max_block_move].tile = objs[x].sprite;
						[currentBoard setTile: block_move[max_block_move].tile forRow:block_move[max_block_move].yblk column:block_move[max_block_move].xblk];
						max_block_move++;
                        }
                     else if (!done)
                        objs[x].time++;
                     break;
                  case 3:
                     for (Character *guard in guards)
                        {
                        if ([guard xblk] == objs[x].xblk && [guard yblk] + 1 == objs[x].yblk)
                           {
                           objs[x].state = 9;
                           objs[x].time = DISINTEGRATION_RATE;
                           [runner setTime:0];
                           done = TRUE;
                           }
                        }
                     if (!done && objs[x].time == DISINTEGRATION_RATE)
                        {
						[currentBoard setCharacteristic:(TILE_AIR | TILE_DUG) forRow:objs[x].yblk column:objs[x].xblk];
                        objs[x].state = 4;
                        objs[x].time = 0;
                        objs[x].sprite++;
                        block_move[max_block_move].active = YES;
                        block_move[max_block_move].mode = 0;
                        block_move[max_block_move].xblk = objs[x].xblk;
                        block_move[max_block_move].yblk = objs[x].yblk;
                        block_move[max_block_move].tile = objs[x].sprite;
						[currentBoard setTile: block_move[max_block_move].tile forRow:block_move[max_block_move].yblk column:block_move[max_block_move].xblk];
						max_block_move++;
                        }
                     else if (!done)
                        objs[x].time++;
                     break;
                  case 4:
                     if (objs[x].time == DISINTEGRATION_RATE)
                        {
						[runner setTime:0];
                        objs[x].state = 5;
                        objs[x].time = 0;
                        block_move[max_block_move].active = YES;
                        block_move[max_block_move].mode = 0;
                        block_move[max_block_move].xblk = objs[x].xblk;
                        block_move[max_block_move].yblk = objs[x].yblk;
                        block_move[max_block_move].tile = objs[x].sky;
						[currentBoard setTile: block_move[max_block_move].tile forRow:block_move[max_block_move].yblk column:block_move[max_block_move].xblk];
						max_block_move++;
                        }
                     else
                        objs[x].time++;
                     break;
                  case 5:
                     if (objs[x].time == HOLE_DURATION)
                        {
						[currentBoard setCharacteristic:(TILE_STONE | TILE_DUG) forRow:objs[x].yblk column:objs[x].xblk];
                        objs[x].state = 6;
                        objs[x].time = 0;
                        block_move[max_block_move].active = YES;
                        block_move[max_block_move].mode = 0;
                        block_move[max_block_move].xblk = objs[x].xblk;
                        block_move[max_block_move].yblk = objs[x].yblk;
                        block_move[max_block_move].tile = objs[x].sprite;
						[currentBoard setTile: block_move[max_block_move].tile forRow:block_move[max_block_move].yblk column:block_move[max_block_move].xblk];
						max_block_move++;
						for (Character *guard in guards)
                           {
                           if (objs[x].xblk == [guard xblk] && (objs[x].yblk == [guard yblk] || ([guard yblk] + 1 == objs[x].yblk && [guard ypos] % [currentBoard tileHeight])))
                              {
                              if ([guard time] > 1)
                                 {
								 [self Guard_Die:[guards indexOfObject:guard]];
								 }
                              else
                                 {
                                 [guard setTime:TIME_STUCK];
                                 [guard setDir:UP];
                                 [guard setFall:0];
                                 }
                              }
                           }
					   if (objs[x].xblk == [runner xblk] && (objs[x].yblk == [runner yblk] || ([runner yblk] + 1 == objs[x].yblk && [runner ypos] % [currentBoard tileHeight])))
						  {
							dead = TRUE;
						  }
					   else if ([runner xblk] + 1 == objs[x].xblk && [runner yblk] == objs[x].yblk && ([runner xpos] % [currentBoard tileWidth]))
							{
							dead = TRUE;
							}
                        }
                     else
                        objs[x].time++;
                     break;
                  case 6:
                     for (Character *guard in guards)
                        {
                        if ([guard xblk] == objs[x].xblk && [guard yblk] + 1 == objs[x].yblk)
                           {
                           objs[x].state = 9;
                           objs[x].time = DISINTEGRATION_RATE;
                           done = TRUE;
                           }
                        }
                     if (!done && objs[x].time == DISINTEGRATION_RATE)
                        {
                        objs[x].state = 7;
                        objs[x].time = 0;
                        objs[x].sprite--;
                        block_move[max_block_move].active = YES;
                        block_move[max_block_move].mode = 0;
                        block_move[max_block_move].xblk = objs[x].xblk;
                        block_move[max_block_move].yblk = objs[x].yblk;
                        block_move[max_block_move].tile = objs[x].sprite;
						[currentBoard setTile: block_move[max_block_move].tile forRow:block_move[max_block_move].yblk column:block_move[max_block_move].xblk];
						max_block_move++;
                        if ([runner xblk] == objs[x].xblk && ([runner ypos] == objs[x].yblk || ([runner yblk] + 1 == objs[x].yblk && [runner ypos] % [currentBoard tileHeight])))
							{
							dead = TRUE;
							}
                        }
                     else if (!done)
                        objs[x].time++;
                     break;
                  case 7:
                     for (Character *guard in guards)
                        {
                        if ([guard xblk] == objs[x].xblk && [guard yblk] + 1 == objs[x].yblk)
                           {
                           objs[x].state = 9;
                           objs[x].time = DISINTEGRATION_RATE;
                           done = TRUE;
                           }
                        }
                     if (!done && objs[x].time == DISINTEGRATION_RATE)
                        {
                        objs[x].state = 8;
                        objs[x].time = 0;
                        objs[x].sprite--;
                        block_move[max_block_move].active = YES;
                        block_move[max_block_move].mode = 0;
                        block_move[max_block_move].xblk = objs[x].xblk;
                        block_move[max_block_move].yblk = objs[x].yblk;
                        block_move[max_block_move].tile = objs[x].sprite;
						[currentBoard setTile: block_move[max_block_move].tile forRow:block_move[max_block_move].yblk column:block_move[max_block_move].xblk];
						max_block_move++;
                        if ([runner xblk] == objs[x].xblk && ([runner ypos] == objs[x].yblk || ([runner yblk] + 1 == objs[x].yblk && [runner ypos] % [currentBoard tileHeight])))
							{
							dead = TRUE;
							}
                        }
                     else if (!done)
                        objs[x].time++;
                     break;
                  case 8:
                     for (Character *guard in guards)
                        {
                        if ([guard xblk] == objs[x].xblk && [guard yblk] + 1 == objs[x].yblk)
                           {
                           objs[x].state = 9;
                           objs[x].time = DISINTEGRATION_RATE;
                           done = TRUE;
                           }
                        }
                     if (!done && objs[x].time == DISINTEGRATION_RATE)
                        {
                        objs[x].state = 9;
                        objs[x].time = 0;
                        objs[x].sprite--;
                        block_move[max_block_move].active = YES;
                        block_move[max_block_move].mode = 0;
                        block_move[max_block_move].xblk = objs[x].xblk;
                        block_move[max_block_move].yblk = objs[x].yblk;
                        block_move[max_block_move].tile = objs[x].sprite;
						[currentBoard setTile: block_move[max_block_move].tile forRow:block_move[max_block_move].yblk column:block_move[max_block_move].xblk];
						max_block_move++;
                        if ([runner xblk] == objs[x].xblk && ([runner ypos] == objs[x].yblk  || ([runner yblk] + 1 == objs[x].yblk && [runner ypos] % [currentBoard tileHeight])))
							{
							dead = TRUE;
							}
                        }
                     else if (!done)
                        objs[x].time++;
                     break;
                  case 9:
                     if (objs[x].time == DISINTEGRATION_RATE)
                        {
						[currentBoard setCharacteristic:TILE_BRICK forRow:objs[x].yblk column:objs[x].xblk];
                        objs[x].active = NO;
                        block_move[max_block_move].active = YES;
                        block_move[max_block_move].mode = 0;
                        block_move[max_block_move].xblk = objs[x].xblk;
                        block_move[max_block_move].yblk = objs[x].yblk;
                        block_move[max_block_move].tile = BRICK_TILE;
						[currentBoard setTile: block_move[max_block_move].tile forRow:block_move[max_block_move].yblk column:block_move[max_block_move].xblk];
						max_block_move++;
                        if ([runner xblk] == objs[x].xblk && ([runner ypos] == objs[x].yblk  || ([runner yblk] + 1 == objs[x].yblk && [runner ypos] % [currentBoard tileHeight])))
							{
							dead = TRUE;
							}
                        }
                     else
                        objs[x].time++;
                     break;
                  default:
                     break;
                  }
               break;
            default:
               break;
            }
         }
      }
}

- (void)Remove_Escape
{

   short y;

   escapable = FALSE;

   for (y=0;y<=brd_y_exit;y++)
      {
	  [currentBoard setTile:exit_block[y].tile forRow:y column:brd_x_exit];
	  [currentBoard setCharacteristic:exit_block[y].chr forRow:y column:brd_x_exit];
      block_move[max_block_move].active = YES;
      block_move[max_block_move].mode = 0;
      block_move[max_block_move].xblk = brd_x_exit;
      block_move[max_block_move].yblk = y;
      block_move[max_block_move++].tile = exit_block[y].tile;
      }
}

- (void)Runner_Die
{

	[updateTimer invalidate];
	updateTimer = nil;
	[NSThread sleepForTimeInterval:POST_DIE_SLEEP_DELAY];
	runner_lives--;
	[runner decrementGold];
	if (runner_lives == 0)
		{
		game_mode = 3;
		}
	else
		{
		for (int x=0;x<MAX_MOVE_BLOCKS;x++)
			{
			block_move[x].active = NO;
			block_move[x].mode = 0;
			block_move[x].xblk = 0;
			block_move[x].yblk = 0;
			block_move[x].tile = 0;
			}
		}
}

- (void)Guard_Die:(NSUInteger)guardNum
{

	short				xblk;
	Character			*guard = [guards objectAtIndex:guardNum];

	xblk = random() % [currentBoard boardWidth];

	score += 250;
	if ([guard gold])
		{
		[guard decrementGold];
		if ([currentBoard tileForRow:[guard yblk] column:[guard xblk]] == GROUND_TILE)
			[currentBoard setAttachment:GOLD_TILE_GRND forRow:[guard yblk] column:[guard xblk]];
		else
			[currentBoard setAttachment:GOLD_TILE_SKY forRow:[guard yblk] column:[guard xblk]];
		block_move[max_block_move].active = TRUE;
		block_move[max_block_move].mode = 1;
		block_move[max_block_move].xblk = [guard xblk];
		block_move[max_block_move].yblk = [guard yblk];
		if ([currentBoard tileForRow:[guard yblk] column:[guard xblk]] == SKY_TILE)
			block_move[max_block_move++].tile = GOLD_TILE_SKY;
		else if ([currentBoard tileForRow:[guard yblk] column:[guard xblk]] == GROUND_TILE)
			block_move[max_block_move++].tile = GOLD_TILE_GRND;
		}
	[guard setTime:0];
	[guard setYPos:0];
	[guard setYBlk:0];
	[guard setXPos:(xblk * [currentBoard tileWidth])];
	[guard setXBlk:0];
	[guard setMove:YES];
	[guard setDir:DOWN];
	[self playSound:SOUND_DIE];
}

- (void)Collision_Detection
{

   short blk_x, blk_y;
   short char_height, char_width;

	// First check the runner
	char_width = RUNNER_WIDTH;
	char_height = RUNNER_HEIGHT;
	blk_y = [runner yblk];
	blk_x = [runner xblk];
	if ([currentBoard attachmentForRow:blk_y column:blk_x] && !([runner xpos] % [currentBoard tileWidth]) && !([runner ypos] % [currentBoard tileHeight]))
		{
		[runner incrementGold];
		[self playSound:SOUND_PLGETGLD];
		score += 500;
		[currentBoard setAttachment:0 forRow:blk_y column:blk_x];
		block_move[max_block_move].active = TRUE;
		block_move[max_block_move].mode = 0;
		block_move[max_block_move].xblk = blk_x;
		block_move[max_block_move].yblk = blk_y;
		block_move[max_block_move++].tile = [currentBoard tileForRow:blk_y column:blk_x];
		if ([runner gold] == level_gold)
		   [self Reveal_Escape];
		}
	// Then check the guards
	for (Character *guard in guards)
		{
		char_width = GUARD_WIDTH;
		char_height = GUARD_HEIGHT;
		if (!([guard xpos] + (GUARD_WIDTH - 1) - TOUCH_OFFSET < [runner xpos] + TOUCH_OFFSET || [guard xpos] + TOUCH_OFFSET > [runner xpos] + (RUNNER_WIDTH - 1) - TOUCH_OFFSET
			|| [guard ypos] + (GUARD_HEIGHT - 1) - TOUCH_OFFSET < [runner ypos] + TOUCH_OFFSET || [guard ypos] + TOUCH_OFFSET > [runner ypos] + (RUNNER_HEIGHT - 1) - TOUCH_OFFSET))
			{
			dead = TRUE;
			break;
			}
		else
			{
			blk_y = [guard yblk];
			blk_x = [guard xblk];
			if ([currentBoard attachmentForRow:blk_y column:blk_x] && ![guard gold] && !([guard xpos] % [currentBoard tileWidth]) && !([guard ypos] % [currentBoard tileHeight]))
				{
				[guard incrementGold];
				[self playSound:SOUND_GDGETGLD];
				[currentBoard setAttachment:0 forRow:blk_y column:blk_x];
				block_move[max_block_move].active = TRUE;
				block_move[max_block_move].mode = 0;
				block_move[max_block_move].xblk = blk_x;
				block_move[max_block_move].yblk = blk_y;
				block_move[max_block_move++].tile = [currentBoard tileForRow:blk_y column:blk_x];
				}
			}
      }
}

- (void)Reveal_Escape
{

   short y;
   unsigned char tilenum;

   escapable = 1;

   for (y=brd_y_exit;y>=0;y--)
      {
      if ([currentBoard characteristicForRow:y column:brd_x_exit] & TILE_AIR)
         {
         if ([currentBoard characteristicForRow:y column:brd_x_exit] & TILE_SKY)
            tilenum = SKY_LADDER;
         else
            tilenum = GROUND_LADDER;
         }
      else if ([currentBoard characteristicForRow:(y + 1) column:brd_x_exit] & TILE_NONSOLID)
         {
         if ([currentBoard characteristicForRow:(y + 1) column:brd_x_exit] & TILE_SKY)
            tilenum = SKY_LADDER;
         else
            tilenum = GROUND_LADDER;
         }
      else if (([currentBoard characteristicForRow:y column:(brd_x_exit - 1)] & TILE_SKY) || ([currentBoard characteristicForRow:y column:(brd_x_exit + 1)] & TILE_SKY))
         tilenum = SKY_LADDER;
      else
         tilenum = GROUND_LADDER;

      exit_block[y].xblk = brd_x_exit;
      exit_block[y].yblk = y;
      exit_block[y].tile = [currentBoard tileForRow:y column:brd_x_exit];
      exit_block[y].chr = [currentBoard characteristicForRow:y column:brd_x_exit];

      [currentBoard setTile:tilenum forRow:y column:brd_x_exit];
      if (tilenum == SKY_LADDER)
         [currentBoard setTile:(TILE_LADDER & TILE_SKY) forRow:y column:brd_x_exit];
      else
         [currentBoard setCharacteristic:TILE_LADDER forRow:y column:brd_x_exit];

      block_move[max_block_move].active = TRUE;
      block_move[max_block_move].mode = FALSE;
      block_move[max_block_move].xblk = brd_x_exit;
      block_move[max_block_move].yblk = y;
      block_move[max_block_move++].tile = tilenum;
      }
	for (y=0;y<MAX_OBJECTS;y++)
		{
		if (objs[y].active && objs[y].type == OBJECT_TYPE_HOLE)
			{
			if (objs[y].xblk == brd_x_exit && objs[y].yblk <= brd_y_exit)
				{
				objs[y].active = 0;
				}
			}
		}
}

- (BOOL)Dig_Hole
{

   short x, blk_x, blk_y, dig = 0, dig_left;
   unsigned char tilenum;

   if ([runner ypos] % [currentBoard tileHeight])
      return (FALSE);

   if ([runner dir] == LEFT || [runner dir] == DOWN || ([runner dir] == STOP && !([runner sprite] >= RUNNER_RIGHT_START && [runner sprite] <= RUNNER_RIGHT_END)))
      {
      if (!([runner xpos] % [currentBoard tileWidth]))
         blk_x = ([runner xpos] / [currentBoard tileWidth]) - 1;
      else
         blk_x = [runner xpos] / [currentBoard tileWidth];
      dig_left = TRUE;
      }
   else
      {
      blk_x = ([runner xpos] / [currentBoard tileWidth]) + 1;
      dig_left = FALSE;
      }
   blk_y = ([runner ypos] / [currentBoard tileHeight]) + 1;

   if (([currentBoard characteristicForRow:blk_y column:blk_x] & TILE_BRICK) && ([currentBoard characteristicForRow:(blk_y - 1) column:blk_x] & TILE_DIG_UNDER) && !([currentBoard attachmentForRow:(blk_y - 1) column:blk_x] == GOLD_TILE_SKY) && !([currentBoard attachmentForRow:(blk_y - 1) column:blk_x] == GOLD_TILE_GRND))
      dig = TRUE;

   if (dig)
      {
		[self playSound:SOUND_DIG];
      if (([runner xpos] % [currentBoard tileWidth]) && dig_left)
         {
         [runner setXPos:([runner xpos] + [currentBoard tileWidth] - ([runner xpos] % [currentBoard tileWidth]))];
         [runner setXBlk:([runner xpos] / [currentBoard tileWidth])];
         }
      else if (([runner xpos] % [currentBoard tileWidth]) && !dig_left)
         {
         [runner setXPos:([runner xpos] - [runner xpos] % [currentBoard tileWidth])];
         [runner setYBlk:([runner ypos] / [currentBoard tileHeight])];
         }
	  [currentBoard setCharacteristic:(TILE_STONE | TILE_DUG) forRow:blk_y column:blk_x];
      if ((blk_y < ([currentBoard boardHeight] - 1) && ([currentBoard tileForRow:(blk_y + 1) column:blk_x] & TILE_SKY)) || ([currentBoard tileForRow:blk_y column:blk_x - 1] & TILE_SKY) || ([currentBoard tileForRow:blk_y column:blk_x + 1] & TILE_SKY))
         tilenum = STRT_DIG_SKY;
      else
         tilenum = STRT_DIG_GRND;
      x = 0;
      while (objs[x].active && x < MAX_OBJECTS)
         x++;
      objs[x].active = YES;
      objs[x].type = OBJECT_TYPE_HOLE;
      objs[x].state = 1;
      objs[x].sprite = tilenum;
      objs[x].xpos = blk_x * [currentBoard tileWidth];
      objs[x].ypos = blk_y * [currentBoard tileHeight];
      objs[x].xblk = blk_x;
      objs[x].yblk = blk_y;
      objs[x].time = 0;
      if (tilenum == STRT_DIG_SKY)
         objs[x].sky = SKY_TILE;
      else
         objs[x].sky = GROUND_TILE;
      block_move[max_block_move].active = YES;
      block_move[max_block_move].mode = 0;
      block_move[max_block_move].xblk = blk_x;
      block_move[max_block_move].yblk = blk_y;
      block_move[max_block_move].tile = tilenum;
	  [currentBoard setTile: block_move[max_block_move].tile forRow:block_move[max_block_move].yblk column:block_move[max_block_move].xblk];
	  max_block_move++;
      }
   return (dig);
}

- (void)Win_Board
{

	short x;

	[updateTimer invalidate];
	updateTimer = nil;
	[self playSound:SOUND_WIN];
	[NSThread sleepForTimeInterval:POST_WIN_BOARD_SLEEP_DELAY];
	escapable = 0;
	runner_lives++;
	if (level < 33)
		{
		level++;
		if (level > maxLevel)
			{
			maxLevel = level;
			startLevelControl.minimumValue = 1;
			startLevelControl.maximumValue = maxLevel;
			[self writePrefsFile];
			}
		}
	else
		{
		level = 1;
		}

	score += 1000;

	for (int x=0;x<MAX_MOVE_BLOCKS;x++)
		{
		block_move[x].active = NO;
		block_move[x].mode = 0;
		block_move[x].xblk = 0;
		block_move[x].yblk = 0;
		block_move[x].tile = 0;
		}

	for (x=0;x<MAX_OBJECTS;x++)
		objs[x].active = NO;

	max_block_move = 0;
	game_mode = 1;
}

- (void)Enter_High_Score
{

    [window addSubview:enterHSView];
	[highScoreName becomeFirstResponder];
}

- (NSMutableArray *)guards
{
	return guards;
}

- (short)controller_dir
{
	return controller_dir;
}

- (Character *)runner
{
	return runner;
}

- (Gameboard *)currentBoard
{
	return currentBoard;
}

- (int)max_block_move
{
	return max_block_move;
}

- (BOOL)runner_dig
{
	return runner_dig;
}

- (BOOL)upButtonPressed
{
	return upButtonPressed;
}

- (BOOL)downButtonPressed
{
	return downButtonPressed;
}

- (BOOL)leftButtonPressed
{
	return leftButtonPressed;
}

- (BOOL)rightButtonPressed
{
	return rightButtonPressed;
}

- (int)screenOrientation
{
	return screenOrientation;
}

- (int)controlStyle
{
	return controlStyle;
}

- (BOOL)acceptingInput
{
	return acceptingInput;
}

- (void)setController_dir:(short)newDir
{

	// If button is pressed during curtain reveal, abort the reveal
	if (curtainTimer)
		{
		[self finishReveal];
		return;
		}
	else
		{
		controller_dir = newDir;
		}
}

- (void)setLeftButtonPressed:(BOOL)state
{

	// If button is pressed during curtain reveal, abort the reveal
	if (curtainTimer)
		{
		[self finishReveal];
		return;
		}

	leftButtonPressed = state;
}

- (void)setRightButtonPressed:(BOOL)state
{

	// If button is pressed during curtain reveal, abort the reveal
	if (curtainTimer)
		{
		[self finishReveal];
		return;
		}

	rightButtonPressed = state;
}

- (void)setUpButtonPressed:(BOOL)state
{

	// If button is pressed during curtain reveal, abort the reveal
	if (curtainTimer)
		{
		[self finishReveal];
		return;
		}

	upButtonPressed = state;
}

- (void)setDownButtonPressed:(BOOL)state
{

	// If button is pressed during curtain reveal, abort the reveal
	if (curtainTimer)
		{
		[self finishReveal];
		return;
		}

	downButtonPressed = state;
}

- (void)setTouchStartPosition:(CGPoint)startPoint
{
	touchStartPosition.x = startPoint.x;
	touchStartPosition.y = startPoint.y;
}

- (void)setRunner_dig:(BOOL)newDig
{

	// If button is pressed during curtain reveal, abort the reveal
	if (curtainTimer)
		{
		[self finishReveal];
		return;
		}

	runner_dig = newDig;
	[self setController_dir:STOP];
}

- (void)incrementScore:(int)addToScore
{
	score += addToScore;
}

- (void)incrementMaxBlockMove
{
	max_block_move++;
}

@end
