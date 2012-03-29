//
//  IRDiscreteLayoutGrid.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutGrid.h"
#import "IRDiscreteLayoutGrid+Private.h"
#import "IRDiscreteLayoutError.h"
#import "IRDiscreteLayoutGrid+DebugSupport.h"


@interface IRDiscreteLayoutGrid ()
@property (nonatomic, readwrite, retain) IRDiscreteLayoutGrid *prototype;
@property (nonatomic, readwrite, retain) NSArray *layoutAreaNames;
@property (nonatomic, readwrite, retain) NSMutableDictionary *layoutAreaNamesToValidatorBlocks;
@property (nonatomic, readwrite, retain) NSMutableDictionary *layoutAreaNamesToLayoutBlocks;
@property (nonatomic, readwrite, retain) NSMutableDictionary *layoutAreaNamesToLayoutItems;
@property (nonatomic, readwrite, retain) NSMutableDictionary *layoutAreaNamesToDisplayBlocks;
@end


@implementation IRDiscreteLayoutGrid
@synthesize contentSize, prototype;
@synthesize layoutAreaNames;
@synthesize layoutAreaNamesToLayoutBlocks, layoutAreaNamesToValidatorBlocks, layoutAreaNamesToLayoutItems, layoutAreaNamesToDisplayBlocks;
@synthesize populationInspectorBlock;
@synthesize allowsPartialInstancePopulation;

+ (IRDiscreteLayoutGrid *) prototype {

	return [[[self alloc] init] autorelease];

}

- (IRDiscreteLayoutGrid *) instantiatedGrid {

	NSParameterAssert(!self.prototype);

	IRDiscreteLayoutGrid *returnedGrid = [self copy];
	returnedGrid.prototype = self;
	
	return [returnedGrid autorelease];

}

- (IRDiscreteLayoutGrid *) instantiatedGridWithAvailableItems:(NSArray *)items {

	return [self instantiatedGridWithAvailableItems:items error:nil];

}

- (IRDiscreteLayoutGrid *) instantiatedGridWithAvailableItems:(NSArray *)items error:(NSError **)outError {

	NSParameterAssert(!self.prototype);
	
	outError = outError ? outError : &(NSError *){ nil };

	//	This base implementation simply fills the grid up with some available items at the beginning of the array
	//	Subclasses can probably swizzle the prototype, and return a new instantiated grid
	
	NSUInteger numberOfItems = [items count];
	if (!numberOfItems) {
		*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridFulfillmentFailureError, @"Could not instantiate a grid with no layout items given.", nil);
		return nil;
	}
	
	NSMutableArray *nonHandledItems = [[items mutableCopy] autorelease];
	NSMutableArray *consumedItems = [NSMutableArray array];
	
	IRDiscreteLayoutGrid *instance = [self instantiatedGrid];
	
	__block BOOL canContinue = (numberOfItems > 0);
	__block BOOL hasSkippedItem = NO;
		
	while (canContinue) {
	
		id nextItem = [nonHandledItems objectAtIndex:0];
		__block BOOL hasClaimedItem = NO;

		[instance enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
		
			if (hasClaimedItem || [instance layoutItemForAreaNamed:name])
				return;
			
			if (![instance setLayoutItem:nextItem forAreaNamed:name error:nil])
				return;

			[nonHandledItems removeObject:nextItem];
			[consumedItems addObject:nextItem];
			hasClaimedItem = YES;				
			
		}];
		
		if (!hasClaimedItem) {
		
			[nonHandledItems removeObject:nextItem];
			hasSkippedItem = YES;
			
		}
		
		canContinue = !![nonHandledItems count];
		
	}
	
	//	The first item provided must be consumed.
	
	if (![consumedItems containsObject:[items objectAtIndex:0]]) {
		*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridFulfillmentFailureError, @"Could not instantiate a grid skipping the first given layout item.", nil);
		return nil;
	}
	
	if (![consumedItems count]) {
		*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridFulfillmentFailureError, @"Could not instantiate a grid without consuming any given layout item.", nil);
		return nil;
	}
	
	if ([instance isFullyPopulated])
		return instance;
	
	//	The instance is not fully populated.  Still allow the result to stand its chance as long as it is the last page
	//	Issue: disallow leading spaces, must fill area and can not skip an area without filling it
	
	__block BOOL hasFoundWhitespace = NO;
	__block BOOL hasGap = NO;

	[instance enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
		
		if (item) {
			
			if (hasFoundWhitespace)
				hasGap = YES;
						
		} else {
		
			hasFoundWhitespace = YES;
		
		}
		
	}];
	
	if (hasGap) {
		*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridFulfillmentFailureError, @"Prospective grid has unfilled layout areas between filled layout areas.", nil);
		return nil;
	}
	
	if (![nonHandledItems count])
	if (!hasSkippedItem)
		return instance;
	
	if (self.allowsPartialInstancePopulation) {
	
		//	TBD: disallow spaces between items
		
		return instance;
		
	}
	
	*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridFulfillmentFailureError, @"Grid prototype forbids partial instantiation with leftover layout areas.", nil);
	
	return nil;

}

- (id) init {

	self = [super init];
	if (!self)
		return nil;
		
	layoutAreaNames = [[NSArray array] retain];
	layoutAreaNamesToLayoutBlocks = [[NSMutableDictionary dictionary] retain];
	layoutAreaNamesToLayoutItems = [[NSMutableDictionary dictionary] retain];
	layoutAreaNamesToValidatorBlocks = [[NSMutableDictionary dictionary] retain];
	layoutAreaNamesToDisplayBlocks = [[NSMutableDictionary dictionary] retain];
	allowsPartialInstancePopulation = NO;
	
	return self;

}

- (void) dealloc {

	[prototype release];
	[layoutAreaNames release];
	[layoutAreaNamesToLayoutBlocks release];
	[layoutAreaNamesToValidatorBlocks release];
	[layoutAreaNamesToLayoutItems release];
	[layoutAreaNamesToDisplayBlocks release];
	
	[populationInspectorBlock release];
	
	[super dealloc];

}

- (id) copyWithZone:(NSZone *)zone {

	IRDiscreteLayoutGrid *copiedGrid = [[IRDiscreteLayoutGrid allocWithZone:zone] init];
	copiedGrid.identifier = self.identifier;
	copiedGrid.prototype = self.prototype;
	copiedGrid.contentSize = self.contentSize;
	copiedGrid.layoutAreaNames = [[self.layoutAreaNames copy] autorelease];
	copiedGrid.layoutAreaNamesToLayoutBlocks = [[self.layoutAreaNamesToLayoutBlocks mutableCopy] autorelease];
	copiedGrid.layoutAreaNamesToLayoutItems = [[self.layoutAreaNamesToLayoutItems mutableCopy] autorelease];
	copiedGrid.layoutAreaNamesToValidatorBlocks = [[self.layoutAreaNamesToValidatorBlocks mutableCopy] autorelease];
	copiedGrid.layoutAreaNamesToDisplayBlocks = [[self.layoutAreaNamesToDisplayBlocks mutableCopy] autorelease];
	copiedGrid.allowsPartialInstancePopulation = self.allowsPartialInstancePopulation;
	return copiedGrid;

}

- (void) registerLayoutAreaNamed:(NSString *)aName validatorBlock:(BOOL(^)(IRDiscreteLayoutGrid *self, id anItem))aValidatorBlock layoutBlock:(CGRect(^)(IRDiscreteLayoutGrid *self, id anItem))aLayoutBlock displayBlock:(id(^)(IRDiscreteLayoutGrid *self, id anItem))aDisplayBlock {

	NSParameterAssert(!self.prototype);
	NSParameterAssert(aLayoutBlock);
	
	[[self mutableArrayValueForKey:@"layoutAreaNames"] addObject:aName];
	
	if (aValidatorBlock)
		[self.layoutAreaNamesToValidatorBlocks setObject:[[aValidatorBlock copy] autorelease] forKey:aName];
	
	if (aLayoutBlock)
		[self.layoutAreaNamesToLayoutBlocks setObject:[[aLayoutBlock copy] autorelease] forKey:aName];
		
	if (aDisplayBlock)
		[self.layoutAreaNamesToDisplayBlocks setObject:[[aDisplayBlock copy] autorelease] forKey:aName];

}

- (NSUInteger) numberOfLayoutAreas {

	return [self.layoutAreaNames count];
	
}

- (void) setLayoutItem:(id)aLayoutItem forAreaNamed:(NSString *)anAreaName {

	[self setLayoutItem:aLayoutItem forAreaNamed:anAreaName error:nil];

}

- (BOOL) setLayoutItem:(id)aLayoutItem forAreaNamed:(NSString *)anAreaName error:(NSError **)outError {
	
	NSParameterAssert(self.prototype);
	NSParameterAssert(anAreaName);
	
	outError = outError ? outError : &(NSError *){ nil };
	
	IRDiscreteLayoutGridAreaValidatorBlock validatorBlock = [self.layoutAreaNamesToValidatorBlocks objectForKey:anAreaName];
	if (aLayoutItem && validatorBlock && !validatorBlock(self, aLayoutItem)) {
		
		*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridItemValidationFailureError, [NSString stringWithFormat:@"Item %@ is not accepted by the validator block of area named %@", aLayoutItem, anAreaName], nil);
		return NO;
		
	}
	
	if (aLayoutItem)
		[self.layoutAreaNamesToLayoutItems setObject:aLayoutItem forKey:anAreaName];
	else
		[self.layoutAreaNamesToLayoutItems removeObjectForKey:anAreaName];

	return YES;

}

- (id) layoutItemForAreaNamed:(NSString *)anAreaName {

	return [self.layoutAreaNamesToLayoutItems objectForKey:anAreaName];

}

- (NSString *) layoutAreaNameForItem:(id)anItem {

	NSParameterAssert(self.prototype);
	
	__block NSString *foundName = nil;
	
	[self.layoutAreaNamesToLayoutItems enumerateKeysAndObjectsUsingBlock: ^ (NSString *name, id item, BOOL *stop) {
	
		if (item == anItem) {
		
			foundName = name;
			*stop = YES;
		
		}
		
	}];
	
	return foundName;

}

- (void) enumerateLayoutAreaNamesWithBlock:(void(^)(NSString *anAreaName))aBlock {

	if (!aBlock)
		return;

	for (NSString *aName in self.layoutAreaNames)
		aBlock(aName);

}

- (void) enumerateLayoutAreasWithBlock:(void(^)(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock))aBlock {
	
	if (!aBlock)
		return;

	[self enumerateLayoutAreaNamesWithBlock:^(NSString *anAreaName) {
	
		aBlock(
			anAreaName,
			[self.layoutAreaNamesToLayoutItems objectForKey:anAreaName],
			[self.layoutAreaNamesToValidatorBlocks objectForKey:anAreaName],
			[self.layoutAreaNamesToLayoutBlocks objectForKey:anAreaName],
			[self.layoutAreaNamesToDisplayBlocks objectForKey:anAreaName]
		);
		
	}];

}

- (void) setValidatorBlock:(IRDiscreteLayoutGridAreaValidatorBlock)block forAreaNamed:(NSString *)name {

	[self.layoutAreaNamesToValidatorBlocks setObject:block forKey:name];

}

- (IRDiscreteLayoutGridAreaValidatorBlock) validatorBlockForAreaNamed:(NSString *)name {

	return [self.layoutAreaNamesToValidatorBlocks objectForKey:name];

}

- (void) setLayoutBlock:(IRDiscreteLayoutGridAreaLayoutBlock)block forAreaNamed:(NSString *)name {

	[self.layoutAreaNamesToLayoutBlocks setObject:block forKey:name];

}

- (IRDiscreteLayoutGridAreaLayoutBlock) layoutBlockForAreaNamed:(NSString *)name {

	return [self.layoutAreaNamesToLayoutBlocks objectForKey:name];

}

- (void) setDisplayBlock:(IRDiscreteLayoutGridAreaDisplayBlock)block forAreaNamed:(NSString *)name {

	[self.layoutAreaNamesToDisplayBlocks setObject:block forKey:name];

}

- (IRDiscreteLayoutGridAreaDisplayBlock) displayBlockForAreaNamed:(NSString *)name {

	return [self.layoutAreaNamesToDisplayBlocks objectForKey:name];

}

- (BOOL) isFullyPopulated {

	NSParameterAssert(self.prototype);
	
	if (self.populationInspectorBlock)
		return self.populationInspectorBlock(self);
	
	if (self.prototype.populationInspectorBlock)
		return self.prototype.populationInspectorBlock(self);
	
	__block BOOL answer = YES;
	
	[self enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
	
		if (!item)
			answer = NO;
			
	}];
	
	return answer;

}

@end
