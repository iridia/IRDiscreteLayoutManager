//
//  IRDiscreteLayoutChangeSet.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 3/22/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutChangeSet.h"
#import "IRDiscreteLayoutGrid.h"
#import "IRDiscreteLayoutArea.h"

@interface IRDiscreteLayoutChangeSet ()

@property (nonatomic, readwrite, strong) IRDiscreteLayoutGrid *fromGrid;
@property (nonatomic, readwrite, strong) IRDiscreteLayoutGrid *toGrid;

@end


@implementation IRDiscreteLayoutChangeSet
@synthesize fromGrid, toGrid;

+ (id) changeSetFromGrid:(IRDiscreteLayoutGrid *)fromGrid toGrid:(IRDiscreteLayoutGrid *)toGrid {

	return [[self alloc] initWithSourceGrid:fromGrid destinationGrid:toGrid];

}

- (id) initWithSourceGrid:(IRDiscreteLayoutGrid *)inFromGrid destinationGrid:(IRDiscreteLayoutGrid *)inToGrid {

	self = [super init];
	if (!self)
		return nil;
	
	fromGrid = inFromGrid;
	toGrid = inToGrid;
	
	return self;

}


- (void) enumerateChangesWithBlock:(void (^)(id, IRDiscreteLayoutItemChangeType))block {

	NSParameterAssert(block);

	NSSet *fromItems = ((^ {
	
		NSMutableSet *fromItems = [NSMutableSet setWithCapacity:[self.fromGrid.layoutAreas count]];
		
		[self.fromGrid.layoutAreas enumerateObjectsUsingBlock:^(IRDiscreteLayoutArea *area, NSUInteger idx, BOOL *stop) {
			
			if (area.item)
				[fromItems addObject:area.item];
			
		}];
		
		return fromItems;
	
	})());
	
	NSSet *toItems = ((^ {
	
		NSMutableSet *toItems = [NSMutableSet setWithCapacity:[self.toGrid.layoutAreas count]];
	
		[self.toGrid.layoutAreas enumerateObjectsUsingBlock:^(IRDiscreteLayoutArea *area, NSUInteger idx, BOOL *stop) {
			
			if (area.item)
				[toItems addObject:area.item];
			
		}];
		
		return toItems;
	
	})());
	
	NSValue * const kInserting = [NSNumber numberWithUnsignedInteger:IRDiscreteLayoutItemChangeInserting];
	NSValue * const kDeleting = [NSNumber numberWithUnsignedInteger:IRDiscreteLayoutItemChangeDeleting];
	NSValue * const kRelayout = [NSNumber numberWithUnsignedInteger:IRDiscreteLayoutItemChangeRelayout];
	NSValue * const kNone = [NSNumber numberWithUnsignedInteger:IRDiscreteLayoutItemChangeNone];
	
	NSSet *allItems = [fromItems setByAddingObjectsFromSet:toItems];
	NSMutableDictionary *itemsToChanges = [NSMutableDictionary dictionaryWithCapacity:[allItems count]];
	
	[allItems enumerateObjectsUsingBlock: ^ (id obj, BOOL *stop) {
	
		NSValue *objValue = [NSValue valueWithNonretainedObject:obj];
	
		IRDiscreteLayoutArea *fromArea = [self.fromGrid areaForItem:obj];
		IRDiscreteLayoutArea *toArea = [self.toGrid areaForItem:obj];

		BOOL containedBefore = [fromItems containsObject:obj];
		BOOL containedAfter = [toItems containsObject:obj];
		
		if (containedBefore && containedAfter) {
		
			IRDiscreteLayoutAreaLayoutBlock fromLayoutBlock = fromArea.layoutBlock;
			IRDiscreteLayoutAreaLayoutBlock toLayoutBlock = toArea.layoutBlock;
		
			if (fromLayoutBlock && toLayoutBlock && !CGRectEqualToRect(fromLayoutBlock(fromArea, obj), toLayoutBlock(toArea, obj))) {
				
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

- (NSString *) description {

	NSMutableArray *changes = [NSMutableArray array];
	
	[self enumerateChangesWithBlock:^(id item, IRDiscreteLayoutItemChangeType changeType) {
	
		[changes addObject:[NSString stringWithFormat:@"Item: %@; Change: %@", item, ((^ {
		
			switch (changeType) {
				case IRDiscreteLayoutItemChangeDeleting:
					return @"Deleting";
				case IRDiscreteLayoutItemChangeInserting:
					return @"Inserting";
				case IRDiscreteLayoutItemChangeNone:
					return @"None";
				case IRDiscreteLayoutItemChangeRelayout:
					return @"Relayout";
			}
			
			return @"Unknown";
		
		})())]];
		
	}];

	return [NSString stringWithFormat:@"<%@: 0x%x> { Changes: %@ }", NSStringFromClass([self class]), (unsigned int)self, changes];

}

@end
