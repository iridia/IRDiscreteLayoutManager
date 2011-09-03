//
//  IRDiscreteLayoutGrid+Transforming.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutGrid+Transforming.h"

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
		registry = [(NSMutableDictionary *)cfRegistry retain];
		CFRelease(cfRegistry);
			
	});
	
	return registry;

}

+ (NSMutableDictionary *) transformingMapForGridPrototype:(IRDiscreteLayoutGrid *)gridPrototype {

	NSMutableDictionary *map = [[self transformingMapRegistry] objectForKey:gridPrototype];
	if (!map) {
		map = [NSMutableDictionary dictionary];
		CFDictionarySetValue((CFMutableDictionaryRef)[self transformingMapRegistry], gridPrototype, map);
	}
		
	return map;

}

+ (NSMutableDictionary *) transformingMapForGridPrototype:(IRDiscreteLayoutGrid *)gridPrototype areaName:(NSString *)areaName {

	NSParameterAssert(areaName);
	
	NSMutableDictionary *parentMap = [self transformingMapForGridPrototype:gridPrototype];
	NSMutableDictionary *childMap = [parentMap objectForKey:areaName];
	
	if (!childMap) {
		CFMutableDictionaryRef cfChildMap = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
		CFDictionarySetValue((CFMutableDictionaryRef)parentMap, areaName, cfChildMap);
		childMap = (NSMutableDictionary *)cfChildMap;
		CFRelease(cfChildMap);
	}
	
	return childMap;

}

@end


@implementation IRDiscreteLayoutGrid (Transforming)

+ (void) markAreaNamed:(NSString *)aName inGridPrototype:(IRDiscreteLayoutGrid *)aGrid asEquivalentToAreaNamed:(NSString *)mappedName inGridPrototype:(IRDiscreteLayoutGrid *)mappedGrid {

	CFDictionarySetValue((CFMutableDictionaryRef)[self transformingMapForGridPrototype:aGrid areaName:aName], mappedGrid, mappedName);
	CFDictionarySetValue((CFMutableDictionaryRef)[self transformingMapForGridPrototype:mappedGrid areaName:mappedName], aGrid, aName);

}

- (NSSet *) allTransformablePrototypeDestinations {

	if (self.prototype)
		return [self.prototype allTransformablePrototypeDestinations];
		
	NSMutableDictionary *ownTransformingMap = [[self class] transformingMapForGridPrototype:self];
	
	if ([[ownTransformingMap allKeys] count] != [self.layoutAreaNames count])
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
	
		[self.layoutAreaNames enumerateObjectsUsingBlock: ^ (NSString *aLayoutAreaName, NSUInteger idx, BOOL *stop) {
		
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
	
	IRDiscreteLayoutGrid *returnedGrid = [newGrid instantiatedGrid];
	
	[self enumerateLayoutAreaNamesWithBlock: ^ (NSString *anAreaName) {

		[returnedGrid setLayoutItem:[self layoutItemForAreaNamed:anAreaName] forAreaNamed:CFDictionaryGetValue((CFMutableDictionaryRef)[[self class] transformingMapForGridPrototype:self.prototype areaName:anAreaName], newGrid)];

	}];
		
	return returnedGrid;

}

@end
