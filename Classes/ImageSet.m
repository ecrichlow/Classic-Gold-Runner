/*******************************************************************************
* ImageSet.m
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the implementation for using
*						image files from the MM/1 original
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/09/08		*	EGC	*	File creation date
*	04/23/18		*	EGC *	Updated to properly access embedded resources
*	04/24/18		*	EGC *	Converted to ARC
*******************************************************************************/

#import "ImageSet.h"
#import "Classic_Gold_RunnerAppDelegate.h"

@implementation ImageSet

@synthesize filename;

#pragma mark - Object Lifecycle

- (id)init
{
	
	if (!(self = [super init])) return nil;
	filename = nil;
	images = [NSMutableArray arrayWithCapacity:MAX_NUM_IMAGES];
	imageDataObjects = [NSMutableArray arrayWithCapacity:MAX_NUM_IMAGES];
	appDelegate = (Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate];
	setType = 0;
	return self;
}


#pragma mark - Business Logic

// Read in the tiles from the MM/1 version, which consists of a 4 byte header: 'clp' followed
// by a version number, which should always be 1; Next comes 256 sets of data formatted as:
// 1 byte: "set" - if "set" is 0x80, image data follows; otherwise, no image data for this entry
// If image data, 1 byte: image width, 1 byte: image height, width * height bytes: image data
- (BOOL)loadImages:(NSString *)fileName mode:(int)mode
{

	NSArray				*fileComponents = [fileName componentsSeparatedByString:@"."];
	NSString			*resourceName = [[NSBundle mainBundle] pathForResource:fileComponents[0] ofType:fileComponents[1]];
	NSData				*setData = [NSData dataWithContentsOfFile:resourceName];
	const void			*setBytes = [setData bytes];
	unsigned char		*dataMarker = (unsigned char *)setBytes;			// Starts at the beginning of the header
	unsigned char		header[HEADER_LENGTH + 1];
	int					version = 0;
	unsigned char		imageSlotSet = 0;
	int					setIndex = 0;
	NSData				*imageDataObject = nil;

	memset (header, 0, HEADER_LENGTH + 1);

	setType = mode;

	// Now process the file
	memcpy(header, dataMarker, HEADER_LENGTH);
	if (strcmp(header, IMAGE_MASTER_HEADER))
		{
		return NO;			// imageset file didn't have the right header; it's either corrupt or a phony
		}
	else
		{
		dataMarker += HEADER_LENGTH;
		version = *dataMarker++;
		// Spin through all of the possible images and grab the ones that are there
		for (setIndex=0;setIndex<MAX_NUM_IMAGES;setIndex++)
			{
			imageSlotSet = *dataMarker++;
			if (imageSlotSet == 0x80)
				{
				int width = *dataMarker++;
				int height = *dataMarker++;
				CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
				const void *imageData = [self convertRawToRGBA:dataMarker forWidth:width height:height];
				dataMarker += width * height;
				imageDataObject = [[NSData alloc] initWithBytes:imageData length:(width * height * DEFAULT_BYTES_PER_PIXEL)];
				[imageDataObjects addObject:imageDataObject];
				free (imageData);
				CGDataProviderRef dataProviderRef = CGDataProviderCreateWithCFData ((CFDataRef)imageDataObject);
				UIImage *newImage = [UIImage imageWithCGImage:CGImageCreate(width, height, DEFAULT_BITS_PER_COMPONENT, DEFAULT_BITS_PER_PIXEL, width * DEFAULT_BYTES_PER_PIXEL, colorspace, kCGImageAlphaLast | kCGBitmapByteOrder32Big, dataProviderRef, NULL, NO, kCGRenderingIntentDefault)];
				[images addObject:newImage];
				CGDataProviderRelease (dataProviderRef);
				CGColorSpaceRelease (colorspace);
				}
			}
		}
	return YES;
}

- (const void *)convertRawToRGBA:(unsigned char *)rawData forWidth:(int)width height:(int)height
{

	unsigned char	*imageData = malloc(width * height * DEFAULT_BYTES_PER_PIXEL);
	int				rowIndex = 0;
	int				columnIndex = 0;
	unsigned char	pixel;
	unsigned char	*imageDataIndex = imageData;

	memset (imageData, 0, width * height * DEFAULT_BYTES_PER_PIXEL);
	for (rowIndex=0;rowIndex<height;rowIndex++)
		{
		for (columnIndex=0;columnIndex<width;columnIndex++)
			{
			pixel = (unsigned char)*rawData++;
			*imageDataIndex++ = [[appDelegate customPalette] redComponentForPaletteSlot:pixel];
			*imageDataIndex++ = [[appDelegate customPalette] greenComponentForPaletteSlot:pixel];
			*imageDataIndex++ = [[appDelegate customPalette] blueComponentForPaletteSlot:pixel];
			// The original version drew the black for tiles but not the sprites. We do this to make it work the same way here.
			if (setType)
				*imageDataIndex++ = [[appDelegate customPalette] alphaComponentForPaletteSlot:pixel];
			else
				*imageDataIndex++ = 0xff;
			}
		}
	return (imageData);
}

- (UIImage *)imageForSlot:(int)slotNumber
{
	return ([images objectAtIndex:slotNumber]);
}

/* Just used for debugging */
- (NSMutableArray *)images
{
	return images;
}

@end
