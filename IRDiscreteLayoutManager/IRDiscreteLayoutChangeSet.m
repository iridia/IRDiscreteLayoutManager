//
//  IRDiscreteLayoutChangeSet.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 3/22/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutChangeSet.h"
#import "IRDiscreteLayoutGrid.h"

@interface IRDiscreteLayoutChangeSet ()

@property (nonatomic, readwrite, retain) IRDiscreteLayoutGrid *fromGrid;
@property (nonatomic, readwrite, retain) IRDiscreteLayoutGrid *toGrid;

@end


@implementation IRDiscreteLayoutChangeSet
@synthesize fromGrid, toGrid;

+ (id) changeSetFromGrid:(IRDiscreteLayoutGrid *)fromGrid toGrid:(IRDiscreteLayoutGrid *)toGrid {

	return [[[self alloc] initWithSourceGrid:fromGrid destinationGrid:toGrid] autorelease];

}

- (id) initWithSourceGrid:(IRDiscreteLayoutGrid *)inFromGrid destinationGrid:(IRDiscreteLayoutGrid *)inToGrid {

	self = [super init];
	if (!self)
		return nil;
	
	fromGrid = [inFromGrid retain];
	toGrid = [inToGrid retain];
	
	return self;

}

- (void) dealloc {
	
	[fromGrid release];
	[toGrid release];

	[super dealloc];

}

- (void) enumerateChangesWithBlock:(void (^)(id, IRDiscreteLayoutItemChangeType))block {

	NSParameterAssert(block);

	NSSet *fromItems = ((^ {
	
		NSMutableSet *fromItems = [NSMutableSet setWithCapacity:[self.fromGrid numberOfLayoutAreas]];
	
		[self.fromGrid enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
		
			if (item)
				[fromItems addObject:item];
			
		}];
		
		return fromItems;
	
	})());
	
	NSSet *toItems = ((^ {
	
		NSMutableSet *toItems = [NSMutableSet setWithCapacity:[self.toGrid numberOfLayoutAreas]];
	
		[self.toGrid enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
		
			if (item)
				[toItems addObject:item];
			
		}];
		
		return toItems;
	
	})());
	
	const char * type = @encode(__typeof__(IRDiscreteLayoutItemChangeType));
	
	NSValue * const kInserting = [NSNumber numberWithUnsignedInteger:IRDiscreteLayoutItemChangeInserting];
	NSValue * const kDeleting = [NSNumber numberWithUnsignedInteger:IRDiscreteLayoutItemChangeDeleting];
	NSValue * const kRelayout = [NSNumber numberWithUnsignedInteger:IRDiscreteLayoutItemChangeRelayout];
	NSValue * const kNone = [NSNumber numberWithUnsignedInteger:IRDiscreteLayoutItemChangeNone];
	
	NSSet *allItems = [fromItems setByAddingObjectsFromSet:toItems];
	NSMutableDictionary *itemsToChanges = [NSMutableDictionary dictionaryWithCapacity:[allItems count]];
	
	[allItems enumerateObjectsUsingBlock: ^ (id obj, BOOL *stop) {
	
		NSValue *objValue = [NSValue valueWithNonretainedObject:obj];
	
		BOOL containedBefore = [fromItems containsObject:obj];
		BOOL containedAfter = [toItems containsObject:obj];
		
		if (containedBefore && containedAfter) {
		
			IRDiscreteLayoutGridAreaLayoutBlock fromLayoutBlock = [self.fromGrid layoutBlockForAreaNamed:[self.fromGrid layoutAreaNameForItem:obj]];
			IRDiscreteLayoutGridAreaLayoutBlock toLayoutBlock = [self.toGrid layoutBlockForAreaNamed:[self.toGrid layoutAreaNameForItem:obj]];
			
			if (fromLayoutBlock && toLayoutBlock && !CGRectEqualToRect(fromLayoutBlock(self.fromGrid, obj), toLayoutBlock(self.toGrid, obj))) {
				
				[itemsToChanges setObject:kRelayout forKey:objValue];
				
			} else {
				
				[itemsToChanges setObject:kNone forKey:objValue];
			
			}
		
		} else if (containedBefore && !containedAfter) {
		
			[itemsToChanges setObject:kDeleting forKey:objValue];
		
		} else if (!containedBefore && containedAfter) {

			[itemsToChanges setObject:kInserting forKey:objValue];
		
		} else {
		
			NSParameterAssert(NO);
		
		}
		
	}];
	
	[itemsToChanges enumerateKeysAndObjectsUsingBlock: ^ (NSValue *objValue, NSNumber *changeValue, BOOL *stop) {
	
		IRDiscreteLayoutItemChangeType change = ((^ {
			
			if ([changeValue isEqualToValue:kInserting])
				return IRDiscreteLayoutItemChangeInserting;
			
			if ([changeValue isEqualToValue:kDeleting])
				return IRDiscreteLayoutItemChangeDeleting;

			if ([changeValue isEqualToValue:kRelayout])
				return IRDiscreteLayoutItemChangeRelayout;

			if ([changeValue isEqualToValue:kNone])
				return IRDiscreteLayoutItemChangeNone;

			return IRDiscreteLayoutItemChangeNone;
			
		})());
	
		block([objValue nonretainedObjectValue], change);
		
	}];

}

@end
