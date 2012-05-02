//
//  IRDiscreteLayoutGrid.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutGrid.h"
#import "IRDiscreteLayoutError.h"
#import "IRDiscreteLayoutGrid+DebugSupport.h"
#import "IRDiscreteLayoutItem.h"

#import "IRDiscreteLayoutGrid+SubclassEyesOnly.h"
#import "IRDiscreteLayoutArea.h"

#import "NSArray+IRDiscreteLayoutAdditions.h"


@interface IRDiscreteLayoutGrid ()

- (BOOL) isPrototype;
- (BOOL) isInstance;
- (BOOL) isFullyPopulated;

- (BOOL) hasGap;

- (IRDiscreteLayoutGrid *) newInstance;

@property (nonatomic, readwrite, copy) NSString *identifier;
@property (nonatomic, readwrite, weak) IRDiscreteLayoutGrid *prototype;
@property (nonatomic, readwrite, strong) NSArray *layoutAreas;

@end


@implementation IRDiscreteLayoutGrid
@synthesize prototype, identifier, layoutAreas, contentSize;

- (BOOL) isPrototype {
	
	return !self.prototype;

}

- (BOOL) isInstance {

	return !!self.prototype;

}

- (IRDiscreteLayoutGrid *) newInstance {

	NSParameterAssert([self isPrototype]);
	
	IRDiscreteLayoutGrid *instance = [self copy];
	instance.prototype = self;
	
	return instance;

}

- (id) initWithIdentifier:(NSString *)gridID contentSize:(CGSize)size layoutAreas:(NSArray *)areas {

	self = [super init];
	if (!self)
		return nil;
	
	self.identifier = gridID;
	self.layoutAreas = areas;
	self.contentSize = size;
	
	return self;

}

- (IRDiscreteLayoutGrid *) instanceWithItems:(NSArray *)items error:(NSError **)outError {

	NSParameterAssert(!self.prototype);
	
	NSUInteger numberOfItems = [self.layoutAreas count];
	if (!numberOfItems) {
		if (outError) {
			*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridFulfillmentFailureError, @"Could not instantiate a grid with no layout items given.", nil);
		}
		return nil;
	}
	
	IRDiscreteLayoutGrid *instance = [self newInstance];
	NSArray *possibleLayoutAreaNameCombinations = [instance.layoutAreas irdlPossibleCombinations];
	
	[possibleLayoutAreaNameCombinations enumerateObjectsUsingBlock:^(NSArray *combination, NSUInteger idx, BOOL *stopCombinationEnum) {
	
		[items enumerateObjectsUsingBlock:^(id<IRDiscreteLayoutItem> item, NSUInteger idx, BOOL *stopItemEnum) {
		
			if ([instance isFullyPopulated]) {
				*stopItemEnum = YES;
				*stopCombinationEnum = YES;
				return;
			}
			
			[combination enumerateObjectsUsingBlock:^(IRDiscreteLayoutArea *area, NSUInteger idx, BOOL *stopAreaEnum) {
			
				if (area.item)
					return;
					
				if (![area setItem:item error:nil])
					return;
				
				*stopAreaEnum = YES;
				
				NSLog(@"worked on comb %@", combination);
				
			}];
			
		}];
		
	}];
	
	if (![[instance items] count]) {
		if (outError) {
			*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridFulfillmentFailureError, @"Could not instantiate a grid without consuming any given layout item.", nil);
		}
		return nil;
	}
	
	if ([[instance class] canInstantiateGrid:instance withItems:items error:outError])
		return instance;
	
	return nil;
	
}

+ (BOOL) canInstantiateGrid:(IRDiscreteLayoutGrid *)instance withItems:(NSArray *)providedItems error:(NSError **)outError {

	if ([instance isFullyPopulated])
		return YES;
	
	if ([instance hasGap]) {
		
		*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridFulfillmentFailureError, @"Prospective grid has unfilled layout areas between filled layout areas.", nil);
		return NO;
		
	}
	
	if ([[instance items] count] != [providedItems count])
		return NO;
	
	return YES;

}

- (id) copyWithZone:(NSZone *)zone {

	IRDiscreteLayoutGrid *copiedGrid = [[IRDiscreteLayoutGrid allocWithZone:zone] init];
	copiedGrid.identifier = self.identifier;
	copiedGrid.prototype = self.prototype;
	copiedGrid.contentSize = self.contentSize;
	
	NSMutableArray *deepCopiedLayoutAreas = [NSMutableArray arrayWithCapacity:[self.layoutAreas count]];
	for (IRDiscreteLayoutArea *area in self.layoutAreas) {
	
		IRDiscreteLayoutArea *copiedArea = [area copy];
		copiedArea.item = nil;
		copiedArea.grid = copiedGrid;
		
		[deepCopiedLayoutAreas addObject:copiedArea];
		
	}
	
	copiedGrid.layoutAreas = deepCopiedLayoutAreas;
	
	NSLog(@"%@ %@ -> %@ %@", self, self.layoutAreas, copiedGrid, copiedGrid.layoutAreas);
	
	return copiedGrid;

}

- (BOOL) isFullyPopulated {

	NSParameterAssert(self.prototype);
	
	BOOL answer = YES;
	
	for (IRDiscreteLayoutArea *area in self.layoutAreas)
		if (!area.item)
			answer = NO;
	
	return answer;
	
}

- (BOOL) hasGap {

	BOOL hasFoundWhitespace = NO;
	BOOL answer = NO;
	
	for (IRDiscreteLayoutArea *area in self.layoutAreas) {

		if (area.item) {
			
			if (hasFoundWhitespace)
				answer = YES;
						
		} else {
		
			hasFoundWhitespace = YES;
		
		}
	
	}
	
	return answer;

}

- (IRDiscreteLayoutArea *) areaWithIdentifier:(NSString *)areaID {

	for (IRDiscreteLayoutArea *area in self.layoutAreas)
		if ([area.identifier isEqualToString:areaID])
			return area;
	
	return nil;

}

- (IRDiscreteLayoutArea *) areaForItem:(id<IRDiscreteLayoutItem>)item {

	for (IRDiscreteLayoutArea *area in self.layoutAreas)
		if ([area.item isEqual:item])
			return area;
	
	return nil;

}

- (NSArray *) items {

	NSMutableArray *answer = [NSMutableArray arrayWithCapacity:[self.layoutAreas count]];
	for (IRDiscreteLayoutArea *area in self.layoutAreas)
		if (area.item)
			[answer addObject:area.item];
	
	return answer;

}

@end
