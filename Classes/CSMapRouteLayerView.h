//
//  CSMapRouteLayerView.h
//  mapLines
//
//  Created by Craig on 4/12/09.
//  Copyright Craig Spitzkoff 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CSMapRouteLayerView : UIView
{
	MKMapView* _mapView;
	NSArray* _points;
	UIColor* _lineColor;
}

-(id) initWithRoute:(NSArray*)routePoints mapView:(MKMapView*)mapView;

@property (nonatomic, retain) NSArray* points;
@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic, retain) UIColor* lineColor; 

@end
