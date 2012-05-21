//
//  IRDiscreteLayoutGrid+Transforming.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutArea.h"
#import "IRDiscreteLayoutGrid+Transforming.h"
#import "IRDiscreteLayoutGrid+SubclassEyesOnly.h"

NSString * const kIRDiscreteLayoutGridTransformingMap = @"kIRDiscreteLayoutGridTransformingMap";
NSString * const kIRDiscreteLayoutGridTransformingGrid = @"kIRDiscreteLayoutGridTransformingGrid";
NSString * const kIRDiscreteLayoutGridTransformingGridAreaName = @"kIRDiscreteLayoutGridTransformingAreaName";


@interface IRDiscreteLayoutGrid (TransformingPrivate)

+ (NSMutableDictionary *) transformingMapRegistry;
+ (NSMutableDictionary *) transformingMapForGridPrototype:(IRDiscreteLayoutGrid *)gridPrototype;
+ (NSMutableDictionary *) transformingMapForGridPrototype:(IRDiscreteLayoutGrid *)gridPrototype areaName:(NSString *)areaName;

//	aGridPrototype: {
//		"anAreaName" : {	anotherGrid: anotherAreaName, yetAnotherGrid, yetAnotherAreaName, … }
//	}

@end


@implementation IRDiscreteLayoutGrid (TransformingPrivate)

+ (NSMutableDictionary *) transformingMapRegistry {

	static dispatch_once_t onceToken = 0;
	static NSMutableDictionary *registry = nil;
	dispatch_once(&onceToken, ^{
	
		CFMutableDictionaryRef cfRegistry = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		registry = (__bridge NSMutableDictionary *)cfRegistry;
		CFRelease(cfRegistry);
			
	});
	
	return registry;

}

+ (NSMutableDictionary *) transformingMapForGridPrototype:(IRDiscreteLayoutGrid *)gridPrototype {

	NSMutableDictionary *map = [[self transformingMapRegistry] objectForKey:gridPrototype];
	if (!map) {
		map = [NSMutableDictionary dictionary];
		CFDictionarySetValue((__bridge CFMutableDictionaryRef)[self transformingMapRegistry], (__bridge const void *)(gridPrototype), (__bridge const void *)(map));
	}
		
	return map;

}

+ (NSMutableDictionary *) transformingMapForGridPrototype:(IRDiscreteLayoutGrid *)gridPrototype areaName:(NSString *)areaName {

	NSParameterAssert(areaName);
	
	NSMutableDictionary *parentMap = [self transformingMapForGridPrototype:gridPrototype];
	NSMutableDictionary *childMap = [parentMap objectForKey:areaName];
	
	if (!childMap) {
		CFMutableDictionaryRef cfChildMap = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
		CFDictionarySetValue((__bridge CFMutableDictionaryRef)parentMap, (__bridge const void *)(areaName), cfChildMap);
		childMap = (__bridge NSMutableDictionary *)cfChildMap;
		CFRelease(cfChildMap);
	}
	
	return childMap;

}

@end


@implementation IRDiscreteLayoutGrid (Transforming)

+ (void) markAreaNamed:(NSString *)aName inGridPrototype:(IRDiscreteLayoutGrid *)aGrid asEquivalentToAreaNamed:(NSString *)mappedName inGridPrototype:(IRDiscreteLayoutGrid *)mappedGrid {

	CFDictionarySetValue((__bridge CFMutableDictionaryRef)[self transformingMapForGridPrototype:aGrid areaName:aName], (__bridge const void *)(mappedGrid), (__bridge const void *)(mappedName));
	CFDictionarySetValue((__bridge CFMutableDictionaryRef)[self transformingMapForGridPrototype:mappedGrid areaName:mappedName], (__bridge const void *)(aGrid), (__bridge const void *)(aName));

}

- (NSSet *) allTransformablePrototypeDestinations {

	if (self.prototype)
		return [self.prototype allTransformablePrototypeDestinations];
		
	NSMutableDictionary *ownTransformingMap = [[self class] transformingMapForGridPrototype:self];
	
	if ([[ownTransformingMap allKeys] count] != [self.layoutAreas count])
		return nil;
		
	/*
	
		ownTransformingMap = {
		
			areaname : { grid : areaName, grid : areaName },
			…
		
		};
	
	*/
	
	//	Find all the grids that present in all the mapped area mappings
	
	NSMutableSet *probableGrids = [NSMutableSet set];
	
	[ownTransformingMap enumerateKeysAndObjectsUsingBlock: ^ (NSString *anAreaName, NSDictionary *mappedGridsToMappedAreaNames, BOOL *stop) {
		[probableGrids addObjectsFromArray:[mappedGridsToMappedAreaNames allKeys]];
	}];
	
	return [probableGrids objectsPassingTest: ^ (IRDiscreteLayoutGrid *aProbableGrid, BOOL *stop) {
		
		__block BOOL gridFullfillsLayoutTransformPreconditions = NO;
	
		[self.layoutAreas enumerateObjectsUsingBlock: ^ (IRDiscreteLayoutArea *area, NSUInteger idx, BOOL *stop) {
		
			NSString *aLayoutAreaName = area.identifier;
		
			if (![[[ownTransformingMap objectForKey:aLayoutAreaName] allKeys] containsObject:aProbableGrid])
				return;
			
			gridFullfillsLayoutTransformPreconditions = YES;
			
		}];
		
		return gridFullfillsLayoutTransformPreconditions;
	
	}];

}

- (IRDiscreteLayoutGrid *) transformedGridWithPrototype:(IRDiscreteLayoutGrid *)newGrid {

	NSParameterAssert(self.prototype);
	NSParameterAssert(!newGrid.prototype);
	
	if (self.prototype == newGrid)
		return self;
	
	IRDiscreteLayoutGrid *returnedGrid = [newGrid copy];
	returnedGrid.prototype = newGrid;
	
	[self.layoutAreas enumerateObjectsUsingBlock: ^ (IRDiscreteLayoutArea *area, NSUInteger idx, BOOL *stop) {
	
		NSString *anAreaName = area.identifier;
		NSString *otherAreaName = (__bridge NSString *)(CFDictionaryGetValue((__bridge CFMutableDictionaryRef)[[self class] transformingMapForGridPrototype:self.prototype areaName:anAreaName], (__bridge const void *)(newGrid)));

		IRDiscreteLayoutArea *setArea = [returnedGrid areaWithIdentifier:otherAreaName];

#if !defined(NS_BLOCK_ASSERTIONS)
		
		NSError *error = nil;
		
		BOOL didSetItem = [setArea setItem:area.item error:&error];
		NSCAssert1(didSetItem, @"failed to set item for a proposed corresponding transformation target: %@", error);

#else

		[setArea setItem:area.item error:nil];

#endif

	}];
		
	return returnedGrid;

}

- (IRDiscreteLayoutGrid *) bestCounteprartPrototypeForAspectRatio:(CGFloat)aspectRatio {

	NSParameterAssert(self.prototype);
	NSSet *allIntrospectedGrids = [[self allTransformablePrototypeDestinations] setByAddingObject:self.prototype];
	
	IRDiscreteLayoutGrid *bestGrid = nil;
	
	for (IRDiscreteLayoutGrid *aGrid in allIntrospectedGrids) {
		
		if (!bestGrid) {
			bestGrid = aGrid;
			continue;
		}
		
		CGFloat bestGridAspectRatio = bestGrid.contentSize.width / bestGrid.contentSize.height;
		CGFloat currentGridAspectRatio = aGrid.contentSize.width / aGrid.contentSize.height;
		
		if (fabs(aspectRatio - bestGridAspectRatio) < fabs(aspectRatio - currentGridAspectRatio)) {
			continue;
		}
		
		bestGrid = aGrid;
		
	}

	return bestGrid;

}

@end
