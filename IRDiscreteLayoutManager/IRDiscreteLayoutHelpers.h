//
//  IRDiscreteLayoutHelpers.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 3/23/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IRDiscreteLayoutManager.h"

extern CGRect IRAutoresizedRectMake (CGRect originalRect, CGSize originalBounds, CGSize newBounds, UIViewAutoresizing autoresizingMask);
extern IRDiscreteLayoutGridAreaLayoutBlock IRDiscreteLayoutGridAreaLayoutBlockForConstantSizeMake (CGRect size, CGSize defaultBounds, UIViewAutoresizing autoresizingMask);
extern IRDiscreteLayoutGridAreaLayoutBlock IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake (CGFloat totalUnitsX, CGFloat totalUnitsY, CGFloat unitsOffsetX, CGFloat unitsOffsetY, CGFloat unitsSpanX, CGFloat unitsSpanY);
