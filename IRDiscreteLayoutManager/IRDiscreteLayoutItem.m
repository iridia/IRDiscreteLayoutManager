//
//  IRDiscreteLayoutItem.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutItem.h"


@interface IRDiscreteLayoutItem ()

@property (nonatomic, readwrite, retain) NSArray *representedMediaItems;
@property (nonatomic, readwrite, retain) NSDictionary *itemsToTypes;

@end

@implementation IRDiscreteLayoutItem

@synthesize title, representedMediaItems, itemsToTypes;

- (id) init {

	self = [super init];
	if (!self)
		return nil;
		
	CFMutableDictionaryRef cfItemsToTypes = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
	self.itemsToTypes = (NSDictionary *)cfItemsToTypes;
	CFRelease(cfItemsToTypes);
	
	return self;

}

- (void) dealloc {

	[title release];
	[representedMediaItems release];
	[itemsToTypes release];
	
	[super dealloc];

}

- (BOOL) addMediaItem:(id)anItem withType:(CFStringRef)typeUTI {

	if ([[self.itemsToTypes allKeys] containsObject:anItem])
		return NO;

	CFDictionaryAddValue((CFMutableDictionaryRef)self.itemsToTypes, anItem, typeUTI);
	[[self mutableArrayValueForKey:@"representedMediaItems"] addObject:anItem];
	return YES;

}

- (BOOL) removeMediaItem:(id)anItem {

	if ([[self.itemsToTypes allKeys] containsObject:anItem])
		return NO;
	
	CFDictionaryRemoveValue((CFMutableDictionaryRef)self.itemsToTypes, anItem);
	[[self mutableArrayValueForKey:@"representedMediaItems"] removeObject:anItem];
	return YES;

}

- (CFStringRef) typeForRepresentedMediaItem:(id)anItem {

	NSString *potentialType = [itemsToTypes objectForKey:anItem];
	
	if (potentialType)
		return (CFStringRef)potentialType;

	if ([anItem isKindOfClass:[NSURL class]])
		return kUTTypeURL;
	
	return kUTTypeItem;

}

- (NSString *) representedText {

		return IRDiscreteLayoutItemContentMediaForUTIType(self, kUTTypeText);

}

- (NSURL *) representedImageURI {

	return IRDiscreteLayoutItemContentMediaForUTIType(self, kUTTypeImage);	

}

- (NSURL *) representedVideoURI {

	return IRDiscreteLayoutItemContentMediaForUTIType(self, kUTTypeVideo);

}

@end


id IRDiscreteLayoutItemContentMediaForUTIType (id<IRDiscreteLayoutItem>self, CFStringRef aType) {

	NSArray *itemsWithConformingTypes = [[self representedMediaItems] objectsAtIndexes:[[self representedMediaItems] indexesOfObjectsPassingTest:^BOOL(id aMediaItem, NSUInteger idx, BOOL *stop) {
	
		CFStringRef mediaUTI = (CFStringRef)[self typeForRepresentedMediaItem:aMediaItem];
		return UTTypeConformsTo(mediaUTI, aType);
		
	}]];

	return [itemsWithConformingTypes count] ? [itemsWithConformingTypes objectAtIndex:0] : nil;

};

