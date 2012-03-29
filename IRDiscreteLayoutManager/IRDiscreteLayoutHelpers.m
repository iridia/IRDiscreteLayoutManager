//
//  IRDiscreteLayoutHelpers.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 3/23/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutHelpers.h"

CGRect IRAutoresizedRectMake (CGRect originalRect, CGSize originalBounds, CGSize newBounds, UIViewAutoresizing autoresizingMask) {

	//	Three in the morning, not the best time to reinvent the wheel.
	//	So I stole all the autoresizing code in UIView.
	
	static UIView *referenceBoundingView = nil;
	static UIView *referenceInnerView = nil;
	static dispatch_once_t onceToken = 0;
	dispatch_once(&onceToken, ^ {
		referenceBoundingView = [[UIView alloc] initWithFrame:CGRectZero];
		referenceInnerView = [[UIView alloc] initWithFrame:CGRectZero];
		[referenceBoundingView addSubview:referenceInnerView];
	});
	
	referenceBoundingView.frame = (CGRect){ CGPointZero, originalBounds };
	referenceInnerView.frame = originalRect;
	referenceInnerView.autoresizingMask = autoresizingMask;
	referenceBoundingView.frame = (CGRect){ CGPointZero, newBounds };
	
  return referenceInnerView.frame;

}

IRDiscreteLayoutGridAreaLayoutBlock IRDiscreteLayoutGridAreaLayoutBlockForConstantSizeMake (CGRect size, CGSize defaultBounds, UIViewAutoresizing autoresizingMask) {

	return [[ ^ (IRDiscreteLayoutGrid *self, id anItem) {
	
		if (CGSizeEqualToSize(defaultBounds, self.contentSize))
			return size;
		else
			return IRAutoresizedRectMake(size, defaultBounds, self.contentSize, autoresizingMask);
	
	} copy] autorelease];

}

IRDiscreteLayoutGridAreaLayoutBlock IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake (CGFloat totalUnitsX, CGFloat totalUnitsY, CGFloat unitsOffsetX, CGFloat unitsOffsetY, CGFloat unitsSpanX, CGFloat unitsSpanY) {

	return [[ ^ (IRDiscreteLayoutGrid *self, id anItem) {
		
		CGFloat xFactor = self.contentSize.width / totalUnitsX;
		CGFloat yFactor = self.contentSize.height / totalUnitsY;
		
		CGRect answer = CGRectIntegral((CGRect){
			(CGPoint){
				unitsOffsetX * xFactor,
				unitsOffsetY * yFactor
			},
			(CGSize){
				unitsSpanX * xFactor,
				unitsSpanY * yFactor
			}
		});
			
		return answer;
	
	} copy] autorelease];

};
