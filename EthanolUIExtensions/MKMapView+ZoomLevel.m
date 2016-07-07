//
//  MKMapView+ZoomLevel.m
//  EthanolUIExtensions
//
//  Created by Bastien Falcou on 9/18/14.
//  Copyright (c) 2010 Troy Brant
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MKMapView+ZoomLevel.h"

#define kMercatorOffset 268435456
#define kMercatorRadius 85445659.44705395
#define kEarthCircumference 40075000.0f

#define DEGREES_TO_RADIANS(x) ((x) / 180.0f * M_PI)
#define METERS_TO_MILES(x) ((x) * 0.000621371f)
#define MILES_TO_METERS(x) ((x) * 1609.34f)
#define METERS_TO_FEET(x) ((x) * 3.28084f)
#define FEET_TO_METERS(x) ((x) * 0.3048f)

@implementation MKMapView (ZoomLevel)

#pragma mark - Map conversion methods

+ (double)eth_longitudeToPixelSpaceX:(double)longitude {
  return round(kMercatorOffset + kMercatorRadius * longitude * M_PI / 180.0f);
}

+ (double)eth_latitudeToPixelSpaceY:(double)latitude {
  if (latitude == 90.0) {
    return 0.0;
  } else if (latitude == -90.0) {
    return kMercatorOffset * 2.0;
  } else {
    return round(kMercatorOffset - kMercatorRadius * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
  }
}

+ (double)eth_pixelSpaceXToLongitude:(double)pixelX {
  return ((round(pixelX) - kMercatorOffset) / kMercatorRadius) * 180.0 / M_PI;
}

+ (double)eth_pixelSpaceYToLatitude:(double)pixelY {
  return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - kMercatorOffset) / kMercatorRadius))) * 180.0 / M_PI;
}

#pragma mark - Helper methods

- (MKCoordinateSpan)eth_coordinateSpanWithMapView:(MKMapView *)mapView
                                 centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                     andZoomLevel:(NSUInteger)zoomLevel {
  // convert center coordiate to pixel space
  double centerPixelX = [MKMapView eth_longitudeToPixelSpaceX:centerCoordinate.longitude];
  double centerPixelY = [MKMapView eth_latitudeToPixelSpaceY:centerCoordinate.latitude];
  
  // determine the scale value from the zoom level
  NSInteger zoomExponent = 20 - zoomLevel;
  double zoomScale = pow(2, zoomExponent);
  
  // scale the map’s size in pixel space
  CGSize mapSizeInPixels = mapView.bounds.size;
  double scaledMapWidth = mapSizeInPixels.width * zoomScale;
  double scaledMapHeight = mapSizeInPixels.height * zoomScale;
  
  // figure out the position of the top-left pixel
  double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
  double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
  
  // find delta between left and right longitudes
  CLLocationDegrees minLongitude = [MKMapView eth_pixelSpaceXToLongitude:topLeftPixelX];
  CLLocationDegrees maxLongitude = [MKMapView eth_pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
  CLLocationDegrees longitudeDelta = maxLongitude - minLongitude;
  
  // find delta between top and bottom latitudes
  CLLocationDegrees minLatitude = [MKMapView eth_pixelSpaceYToLatitude:topLeftPixelY];
  CLLocationDegrees maxLatitude = [MKMapView eth_pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
  CLLocationDegrees latitudeDelta = -1 * (maxLatitude - minLatitude);
  
  // create and return the lat/lng span
  MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
  return span;
}

#pragma mark - Public methods

- (void)eth_setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                      zoomLevel:(NSUInteger)zoomLevel
                       animated:(BOOL)animated {
  // clamp large numbers to 28
  zoomLevel = MIN(zoomLevel, 28);
  zoomLevel = MAX(zoomLevel, 1);
  
  // use the zoom level to compute the region
  MKCoordinateSpan span = [self eth_coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
  MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
  
  // set the region like normal
  [self setRegion:region animated:animated];
}

// KMapView cannot display tiles that cross the pole (as these would involve wrapping the map from
// top to bottom, something that a Mercator projection just cannot do).
- (MKCoordinateRegion)eth_coordinateRegionWithCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                             andZoomLevel:(NSUInteger)zoomLevel {
  // clamp lat/long values to appropriate ranges
  centerCoordinate.latitude = MIN(MAX(-90.0, centerCoordinate.latitude), 90.0);
  centerCoordinate.longitude = fmod(centerCoordinate.longitude, 180.0);
  
  // convert center coordiate to pixel space
  double centerPixelX = [MKMapView eth_longitudeToPixelSpaceX:centerCoordinate.longitude];
  double centerPixelY = [MKMapView eth_latitudeToPixelSpaceY:centerCoordinate.latitude];
  
  // determine the scale value from the zoom level
  NSInteger zoomExponent = 20 - zoomLevel;
  double zoomScale = pow(2, zoomExponent);
  
  // scale the map’s size in pixel space
  CGSize mapSizeInPixels = self.bounds.size;
  double scaledMapWidth = mapSizeInPixels.width * zoomScale;
  double scaledMapHeight = mapSizeInPixels.height * zoomScale;
  
  // figure out the position of the left pixel
  double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
  
  // find delta between left and right longitudes
  CLLocationDegrees minLongitude = [MKMapView eth_pixelSpaceXToLongitude:topLeftPixelX];
  CLLocationDegrees maxLongitude = [MKMapView eth_pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
  CLLocationDegrees longitudeDelta = maxLongitude - minLongitude;
  
  // if we’re at a pole then calculate the distance from the pole towards the equator
  // as MKMapView doesn’t like drawing boxes over the poles
  double topPixelY = centerPixelY - (scaledMapHeight / 2);
  double bottomPixelY = centerPixelY + (scaledMapHeight / 2);
  BOOL adjustedCenterPoint = NO;
  if (topPixelY > kMercatorOffset * 2) {
    topPixelY = centerPixelY - scaledMapHeight;
    bottomPixelY = kMercatorOffset * 2;
    adjustedCenterPoint = YES;
  }
  
  // find delta between top and bottom latitudes
  CLLocationDegrees minLatitude = [MKMapView eth_pixelSpaceYToLatitude:topPixelY];
  CLLocationDegrees maxLatitude = [MKMapView eth_pixelSpaceYToLatitude:bottomPixelY];
  CLLocationDegrees latitudeDelta = -1 * (maxLatitude - minLatitude);
  
  // create and return the lat/lng span
  MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
  MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
  // once again, MKMapView doesn’t like drawing boxes over the poles
  // so adjust the center coordinate to the center of the resulting region
  if (adjustedCenterPoint) {
    region.center.latitude = [MKMapView eth_pixelSpaceYToLatitude:((bottomPixelY + topPixelY) / 2.0)];
  }
  
  return region;
}

- (double)eth_zoomLevel {
  MKCoordinateRegion region = self.region;
  
  double centerPixelX = [MKMapView eth_longitudeToPixelSpaceX: region.center.longitude];
  double topLeftPixelX = [MKMapView eth_longitudeToPixelSpaceX: region.center.longitude - region.span.longitudeDelta / 2.0];
  
  double scaledMapWidth = (centerPixelX - topLeftPixelX) * 2.0;
  CGSize mapSizeInPixels = self.bounds.size;
  double zoomScale = scaledMapWidth / mapSizeInPixels.width;
  double zoomExponent = log(zoomScale) / log(2.0);
  double zoomLevel = 20.0 - zoomExponent;
  
  return isnan(zoomLevel) ? 0.0 : zoomLevel;
}

- (void)eth_setZoomLevel:(double)zoomLevel {
  [self eth_setZoomLevel:zoomLevel animated:YES];
}

- (void)eth_setZoomLevel:(double)zoomLevel animated:(BOOL)animated {
  [self eth_setCenterCoordinate:self.centerCoordinate zoomLevel:zoomLevel animated:animated];
}

#pragma mark - Distance calculations

// Calculate diameter in pixels according to radius in meters of the annotation and the zoom level.
// Using formula: http://wiki.openstreetmap.org/wiki/Zoom_levels

- (CGFloat)eth_sizeForDistanceInMeters:(CGFloat)distanceMeters forAreaCloseToLatitude:(CLLocationDegrees)latitude {
  return (distanceMeters / (kEarthCircumference * cos(DEGREES_TO_RADIANS(latitude)) / pow(2, self.eth_zoomLevel + 8))) / 0.3409627122;
}

- (CGFloat)eth_sizeForDistanceInMiles:(CGFloat)distanceMiles forAreaCloseToLatitude:(CLLocationDegrees)latitude {
  return [self eth_sizeForDistanceInMeters:MILES_TO_METERS(distanceMiles) forAreaCloseToLatitude:latitude];
}

- (CGFloat)eth_sizeForDistanceInFeet:(CGFloat)distanceFeet forAreaCloseToLatitude:(CLLocationDegrees)latitude {
  return [self eth_sizeForDistanceInMeters:FEET_TO_METERS(distanceFeet) forAreaCloseToLatitude:latitude];
}

- (CGFloat)eth_sizeForDistanceInMeters:(CGFloat)distanceMeters {
  return [self eth_sizeForDistanceInMeters:distanceMeters forAreaCloseToLatitude:[self centerCoordinate].latitude];
}

- (CGFloat)eth_sizeForDistanceInMiles:(CGFloat)distanceMiles {
  return [self eth_sizeForDistanceInMeters:MILES_TO_METERS(distanceMiles)];
}

- (CGFloat)eth_sizeForDistanceInFeet:(CGFloat)distanceFeet {
  return [self eth_sizeForDistanceInMeters:FEET_TO_METERS(distanceFeet)];
}

@end
