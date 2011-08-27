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
+ (CFMutableDictionaryRef) transformingMapForGridPrototype:(IRDiscreteLayoutGrid *)gridPrototype areaName:(NSString *)areaName;

//	aGridPrototype: {
//		"anAreaName" : {	anotherGrid: anotherAreaName, yetAnotherGrid, yetAnotherAreaName, … }
//	}

@end

@implementation IRDiscreteLayoutGrid (Transforming)

+ (void) markAreaNamed:(NSString *)aName inGridPrototype:(IRDiscreteLayoutGrid *)aGrid asEquivalentToAreaNamed:(NSString *)mappedName inGridPrototype:(IRDiscreteLayoutGrid *)mappedGrid {

	CFDictionarySetValue([self transformingMapForGridPrototype:aGrid areaName:aName], mappedGrid, mappedName);
	CFDictionarySetValue([self transformingMapForGridPrototype:mappedGrid areaName:mappedName], aGrid, aName);

}

- (IRDiscreteLayoutGrid *) transformedGridWithPrototype:(IRDiscreteLayoutGrid *)newGrid {

	//
	NSParameterAssert(self.prototype);
	
	IRDiscreteLayoutGrid *returnedGrid = [newGrid instantiatedGrid];
	
	[self enumerateLayoutAreaNamesWithBlock: ^ (NSString *anAreaName) {

		[returnedGrid setLayoutItem:[self layoutItemForAreaNamed:anAreaName] forAreaNamed:CFDictionaryGetValue([[self class] transformingMapForGridPrototype:self.prototype areaName:anAreaName], newGrid)];

	}];
		
	return returnedGrid;

}

@end
