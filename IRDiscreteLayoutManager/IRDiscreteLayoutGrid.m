//
//  IRDiscreteLayoutGrid.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutGrid.h"

@interface IRDiscreteLayoutGrid ()
@property (nonatomic, readwrite, retain) IRDiscreteLayoutGrid *prototype;

@property (nonatomic, readwrite, retain) NSArray *layoutAreaNames;
@property (nonatomic, readwrite, retain) NSMutableDictionary *layoutAreaNamesToValidatorBlocks;
@property (nonatomic, readwrite, retain) NSMutableDictionary *layoutAreaNamesToLayoutBlocks;
@property (nonatomic, readwrite, retain) NSMutableDictionary *layoutAreaNamesToLayoutItems;

@end

@implementation IRDiscreteLayoutGrid
@synthesize contentSize, prototype;
@synthesize layoutAreaNames;
@synthesize layoutAreaNamesToLayoutBlocks, layoutAreaNamesToValidatorBlocks, layoutAreaNamesToLayoutItems;

- (IRDiscreteLayoutGrid *) instantiatedGrid {

	NSParameterAssert(!self.prototype);

	IRDiscreteLayoutGrid *returnedGrid = [self copy];
	returnedGrid.prototype = self;
	return [returnedGrid autorelease];

}

- (void) dealloc {

	[prototype release];
	[layoutAreaNames release];
	[layoutAreaNamesToLayoutBlocks release];
	[layoutAreaNamesToValidatorBlocks release];
	[layoutAreaNamesToLayoutItems release];
	
	[super dealloc];

}

- (void) registerLayoutAreaNamed:(NSString *)aName validatorBlock:(BOOL(^)(IRDiscreteLayoutGrid *self, id anItem))aValidatorBlock layoutBlock:(CGRect(^)(IRDiscreteLayoutGrid *self, id anItem))aLayoutBlock {

	NSParameterAssert(!self.prototype);
	NSParameterAssert(aLayoutBlock);
	
	[[self mutableArrayValueForKey:@"layoutAreaNames"] addObject:aName];
	
	if (aValidatorBlock)
		[self.layoutAreaNamesToValidatorBlocks setObject:aValidatorBlock forKey:aName];
	
	if (aLayoutBlock)
		[self.layoutAreaNamesToLayoutBlocks setObject:aLayoutBlock forKey:aName];

}

- (NSUInteger) numberOfLayoutAreas {

	return [self.layoutAreaNames count];
	
}

- (void) setLayoutItem:(id)aLayoutItem forAreaNamed:(NSString *)anAreaName {

	NSParameterAssert(self.prototype);
	
	[self.layoutAreaNamesToLayoutItems setObject:aLayoutItem forKey:anAreaName];

}

- (id) layoutItemForAreaNamed:(NSString *)anAreaName {

	return [self.layoutAreaNamesToLayoutItems objectForKey:anAreaName];

}

- (void) enumerateLayoutAreaNamesWithBlock:(void(^)(NSString *anAreaName))aBlock {

	if (!aBlock)
		return;

	for (NSString *aName in self.layoutAreaNames)
		aBlock(aName);

}

- (void) enumerateLayoutAreasWithBlock:(void(^)(NSString *name, id item, IRDiscreteLayoutItemLayoutBlock layoutBlock, IRDiscreteLayoutItemValidatorBlock validatorBlock))aBlock {

	if (!aBlock)
		return;

	[self enumerateLayoutAreaNamesWithBlock:^(NSString *anAreaName) {
	
		aBlock(
			anAreaName,
			[self.layoutAreaNamesToLayoutItems objectForKey:anAreaName],
			[self.layoutAreaNamesToLayoutBlocks objectForKey:anAreaName],
			[self.layoutAreaNamesToValidatorBlocks objectForKey:anAreaName]
		);
		
	}];

}

@end





extern IRDiscreteLayoutItemLayoutBlock IRDiscreteLayoutGridLayoutBlockForConstantSizeMake (CGRect size, CGSize defaultBounds, int autoresizingMask) {

	return [[ ^ (IRDiscreteLayoutGrid *self, id anItem) {
	
		return CGRectZero;
	
	} copy] autorelease];

}