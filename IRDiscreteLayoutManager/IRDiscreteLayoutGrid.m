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
#import "IRDiscreteLayoutItem.h"


@interface IRDiscreteLayoutGrid ()
@property (nonatomic, readwrite, strong) IRDiscreteLayoutGrid *prototype;
@property (nonatomic, readwrite, strong) NSArray *layoutAreaNames;
@property (nonatomic, readwrite, strong) NSMutableDictionary *layoutAreaNamesToValidatorBlocks;
@property (nonatomic, readwrite, strong) NSMutableDictionary *layoutAreaNamesToLayoutBlocks;
@property (nonatomic, readwrite, strong) NSMutableDictionary *layoutAreaNamesToLayoutItems;
@property (nonatomic, readwrite, strong) NSMutableDictionary *layoutAreaNamesToDisplayBlocks;
@end


@implementation IRDiscreteLayoutGrid
@synthesize contentSize, prototype;
@synthesize layoutAreaNames;
@synthesize layoutAreaNamesToLayoutBlocks, layoutAreaNamesToValidatorBlocks, layoutAreaNamesToLayoutItems, layoutAreaNamesToDisplayBlocks;
@synthesize populationInspectorBlock;
@synthesize allowsPartialInstancePopulation;

+ (IRDiscreteLayoutGrid *) prototype {

	return [[self alloc] init];

}

- (IRDiscreteLayoutGrid *) instantiatedGrid {

	NSParameterAssert(!self.prototype);

	IRDiscreteLayoutGrid *returnedGrid = [self copy];
	returnedGrid.prototype = self;
	
	return returnedGrid;

}

- (IRDiscreteLayoutGrid *) instantiatedGridWithAvailableItems:(NSArray *)items {

	NSError *error = nil;
	IRDiscreteLayoutGrid *grid = [self instantiatedGridWithAvailableItems:items error:&error];
	
	if (!grid) {
		return nil;
	}
	
	return grid;

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
	
	IRDiscreteLayoutGrid *instance = [self instantiatedGrid];
	NSMutableArray *consumedItems = [NSMutableArray array];
	
	//	We need to try all the possible combinations for the layout areas
	//	That is, for areas A and B we need to test both A B and B A
	
	__block NSArray * (^possibleCombinations)(NSArray *) = [^ (NSArray *self) {
	
		NSCParameterAssert([self isKindOfClass:[NSArray class]]);
		
		NSUInteger length = [self count];
		if (length <= 1)
			return (NSArray *)[NSArray arrayWithObject:self];
		
		NSMutableArray *answer = [NSMutableArray array];
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:(NSRange){ 0, length }];
		
		for (NSUInteger i = 0; i < length; i++) {
		
			NSMutableIndexSet *usedIndices = [indexSet mutableCopy];
			[usedIndices removeIndex:i];
			
			NSArray *otherObjects = [self objectsAtIndexes:usedIndices];
			NSCParameterAssert([otherObjects isKindOfClass:[NSArray class]]);
			
			for (NSArray *combination in possibleCombinations(otherObjects)) {
				
				NSCParameterAssert([combination isKindOfClass:[NSArray class]]);
				
				NSArray *usedCombination = [combination copy];
				NSArray *baseObjs = [NSArray arrayWithObject:[self objectAtIndex:i]];
				NSArray *addedAnswer = [baseObjs arrayByAddingObjectsFromArray:usedCombination];
				
				[answer addObject:addedAnswer];
				
			}
		
		}
		
		return (NSArray *)[answer copy];
			
	} copy];
	
	NSArray *possibleLayoutAreaNameCombinations = possibleCombinations(self.layoutAreaNames);
	
	[possibleLayoutAreaNameCombinations enumerateObjectsUsingBlock:^(NSArray *combination, NSUInteger idx, BOOL *stopCombinationEnum) {
	
		[items enumerateObjectsUsingBlock:^(id<IRDiscreteLayoutItem> item, NSUInteger idx, BOOL *stopItemEnum) {
		
			if ([instance isFullyPopulated]) {
				*stopItemEnum = YES;
				*stopCombinationEnum = YES;
				return;
			}
			
			[combination enumerateObjectsUsingBlock:^(NSString *layoutAreaName, NSUInteger idx, BOOL *stopAreaEnum) {
				
				if ([instance layoutItemForAreaNamed:layoutAreaName])
					return;
				
				if (![instance setLayoutItem:item forAreaNamed:layoutAreaName error:nil])
					return;
				
				*stopAreaEnum = YES;
				
			}];
			
		}];
		
	}];
	
	[instance enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {

		if (item)
			[consumedItems addObject:item];
		
	}];

	if (![consumedItems count]) {
		*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridFulfillmentFailureError, @"Could not instantiate a grid without consuming any given layout item.", nil);
		return nil;
	}
	
	if ([instance isFullyPopulated])
		return instance;
	
	BOOL hasGap = (^ {
	
		__block BOOL hasFoundWhitespace = NO;
		__block BOOL answer = NO;

		[instance enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
			
			if (item) {
				
				if (hasFoundWhitespace)
					answer = YES;
							
			} else {
			
				hasFoundWhitespace = YES;
			
			}
			
		}];
		
		return answer;
	
	})();
	
	//	If although the grid is not fully populated, it has used up every single item, and has no gap, it’s okay
	
	if (!hasGap)
	if ([consumedItems count] == [items count])
	if (self.allowsPartialInstancePopulation)
		return instance;
	
	//	Otherwise, if it has not used up every item provided and it has at least one gap, dismiss it
	
	if (hasGap) {
		*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridFulfillmentFailureError, @"Prospective grid has unfilled layout areas between filled layout areas.", nil);
		return nil;
	}
	
	*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridFulfillmentFailureError, @"Grid prototype forbids partial instantiation with leftover layout areas.", nil);
	
	return nil;

}

- (id) init {

	self = [super init];
	if (!self)
		return nil;
		
	layoutAreaNames = [NSArray array];
	layoutAreaNamesToLayoutBlocks = [NSMutableDictionary dictionary];
	layoutAreaNamesToLayoutItems = [NSMutableDictionary dictionary];
	layoutAreaNamesToValidatorBlocks = [NSMutableDictionary dictionary];
	layoutAreaNamesToDisplayBlocks = [NSMutableDictionary dictionary];
	allowsPartialInstancePopulation = NO;
	
	return self;

}


- (id) copyWithZone:(NSZone *)zone {

	IRDiscreteLayoutGrid *copiedGrid = [[IRDiscreteLayoutGrid allocWithZone:zone] init];
	copiedGrid.identifier = self.identifier;
	copiedGrid.prototype = self.prototype;
	copiedGrid.contentSize = self.contentSize;
	copiedGrid.layoutAreaNames = [self.layoutAreaNames copy];
	copiedGrid.layoutAreaNamesToLayoutBlocks = [self.layoutAreaNamesToLayoutBlocks mutableCopy];
	copiedGrid.layoutAreaNamesToLayoutItems = [self.layoutAreaNamesToLayoutItems mutableCopy];
	copiedGrid.layoutAreaNamesToValidatorBlocks = [self.layoutAreaNamesToValidatorBlocks mutableCopy];
	copiedGrid.layoutAreaNamesToDisplayBlocks = [self.layoutAreaNamesToDisplayBlocks mutableCopy];
	copiedGrid.allowsPartialInstancePopulation = self.allowsPartialInstancePopulation;
	return copiedGrid;

}

- (void) registerLayoutAreaNamed:(NSString *)aName validatorBlock:(BOOL(^)(IRDiscreteLayoutGrid *self, id anItem))aValidatorBlock layoutBlock:(CGRect(^)(IRDiscreteLayoutGrid *self, id anItem))aLayoutBlock displayBlock:(id(^)(IRDiscreteLayoutGrid *self, id anItem))aDisplayBlock {

	NSParameterAssert(!self.prototype);
	NSParameterAssert(aLayoutBlock);
	
	[[self mutableArrayValueForKey:@"layoutAreaNames"] addObject:aName];
	
	if (aValidatorBlock)
		[self.layoutAreaNamesToValidatorBlocks setObject:[aValidatorBlock copy] forKey:aName];
	
	if (aLayoutBlock)
		[self.layoutAreaNamesToLayoutBlocks setObject:[aLayoutBlock copy] forKey:aName];
		
	if (aDisplayBlock)
		[self.layoutAreaNamesToDisplayBlocks setObject:[aDisplayBlock copy] forKey:aName];

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
	
	IRDiscreteLayoutGridAreaValidatorBlock validatorBlock = [self.layoutAreaNamesToValidatorBlocks objectForKey:anAreaName];
	if (aLayoutItem && validatorBlock && !validatorBlock(self, aLayoutItem)) {
		
		if (outError)
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
