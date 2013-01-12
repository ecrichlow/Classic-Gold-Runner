/*******************************************************************************
* main.m
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This is the code that launches the application
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/02/08		*	EGC	*	File creation date
*******************************************************************************/

#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
