//
//  IRDiscreteLayoutItem.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutItem.h"


@interface IRDiscreteLayoutItem ()

@property (nonatomic, readwrite, strong) NSArray *representedMediaItems;
@property (nonatomic, readwrite, strong) NSDictionary *itemsToTypes;

@end

@implementation IRDiscreteLayoutItem

@synthesize title, representedMediaItems, itemsToTypes;

- (id) init {

	self = [super init];
	if (!self)
		return nil;
		
	CFMutableDictionaryRef cfItemsToTypes = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
	self.itemsToTypes = (__bridge NSDictionary *)cfItemsToTypes;
	self.representedMediaItems = [NSArray array];
	CFRelease(cfItemsToTypes);
	
	return self;

}


- (BOOL) addMediaItem:(id)anItem withType:(CFStringRef)typeUTI {

	if ([[self.itemsToTypes allKeys] containsObject:anItem])
		return NO;

	CFDictionaryAddValue((__bridge CFMutableDictionaryRef)self.itemsToTypes, (__bridge const void *)(anItem), typeUTI);
	[[self mutableArrayValueForKey:@"representedMediaItems"] addObject:anItem];
	return YES;

}

- (BOOL) removeMediaItem:(id)anItem {

	if ([[self.itemsToTypes allKeys] containsObject:anItem])
		return NO;
	
	CFDictionaryRemoveValue((__bridge CFMutableDictionaryRef)self.itemsToTypes, (__bridge const void *)(anItem));
	[[self mutableArrayValueForKey:@"representedMediaItems"] removeObject:anItem];
	return YES;

}

- (CFStringRef) typeForRepresentedMediaItem:(id)anItem {

	NSString *potentialType = [itemsToTypes objectForKey:anItem];
	
	if (potentialType)
		return (__bridge CFStringRef)potentialType;

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

