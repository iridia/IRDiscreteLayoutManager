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
	
		CFMutableDictionaryRef cfRegistry = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
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

- (IRDiscreteLayoutGrid *) transformedGridWithPrototype:(IRDiscreteLayoutGrid *)newGrid {

	//
	NSParameterAssert(self.prototype);
	
	IRDiscreteLayoutGrid *returnedGrid = [newGrid instantiatedGrid];
	
	[self enumerateLayoutAreaNamesWithBlock: ^ (NSString *anAreaName) {

		[returnedGrid setLayoutItem:[self layoutItemForAreaNamed:anAreaName] forAreaNamed:CFDictionaryGetValue((CFMutableDictionaryRef)[[self class] transformingMapForGridPrototype:self.prototype areaName:anAreaName], newGrid)];

	}];
		
	return returnedGrid;

}

@end
