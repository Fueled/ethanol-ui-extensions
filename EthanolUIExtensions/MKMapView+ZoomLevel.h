//
//  MKMapView+ZoomLevel.h
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

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

/**
 *  Sets the center of the map at a given coordinate for a specified zoom level.
 *  @param centerCoordinate Coordinate you want the map to be centered in
 *  @param zoomLevel        Zoom you want to apply to the map
 *  @param animated         Animate transformation (zoom in or out depending on previous zoom level to the new center of the map)
 */
- (void)eth_setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                      zoomLevel:(NSUInteger)zoomLevel
                       animated:(BOOL)animated;

/**
 *  Get coordinates of a region determined according to a specific zoomLevel and a specific center.
 *  @param centerCoordinate Coordinates of the center of the wanted region.
 *  @param zoomLevel        Zoom Level wanted.
 *  @return Coordinates of the corresponding region.
 */
- (MKCoordinateRegion)eth_coordinateRegionWithCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                                  andZoomLevel:(NSUInteger)zoomLevel;

/**
 *  Get/set current zoom level (between 0 and 19). Animated.
 *  @return Zoom level.
 */
@property (nonatomic, assign, setter=eth_setZoomLevel:) double eth_zoomLevel;

/**
 *  Set the current zoom level.
 *
 *  @param zoomLevel The new zoom level
 *  @param animated  Whether or not the change should be animated
 */
- (void)eth_setZoomLevel:(double)zoomLevel animated:(BOOL)animated;

/**
 *  Return a distance in pixels (that you can use to draw something on the map for example) from a distance
 *  and a latitude located close to the area you want to consider. Indeed, according to the area, distances
 *  on the map don't represent the same actual distance in meters; that's why it is important to specify a
 *  latitude close to your area.
 *  @param distanceMeters Distance in meters you want to convert in pixels.
 *  @param latitude       Latitude close to the location you want to get a distance in pixel from.
 *  @return Distance in pixels that you can directly use to draw a frame for example. This frame will
 *  represent on the map exatly the distance you specified in meters.
 */
- (CGFloat)eth_sizeForDistanceInMeters:(CGFloat)distanceMeters forAreaCloseToLatitude:(CLLocationDegrees)latitude;

/**
 *  Same as above, in miles.
 *  @param distanceMiles Distance in miles you want to convert in pixels.
 *  @param latitude      Latitude close to the location you want to get a distance in pixel from.
 *  @return Distance in pixels that you can directly use to draw a frame for example. This frame will
 *  represent on the map exatly the distance you specified in miles.
 */
- (CGFloat)eth_sizeForDistanceInMiles:(CGFloat)distanceMiles forAreaCloseToLatitude:(CLLocationDegrees)latitude;

/**
 *  Same as above, in feet.
 *  @param distanceFeet Distance in feet you want to convert in pixels.
 *  @param latitude     Latitude close to the location you want to get a distance in pixel from.
 *  @return Distance in pixels that you can directly use to draw a frame for example. This frame will
 *  represent on the map exatly the distance you specified in feet.
 */
- (CGFloat)eth_sizeForDistanceInFeet:(CGFloat)distanceFeet forAreaCloseToLatitude:(CLLocationDegrees)latitude;

/**
 *  Same as above, in meters. Interesting thing with this method, you don't need to specify a latitude
 *  close to your area. The latitude of the center of your map will be used.
 *  @param distanceMeters Distance in meters you want to convert in pixels.
 *  @return Distance in pixels that you can directly use to draw a frame for example. This frame will
 *  represent on the map exatly the distance you specified in meters.
 */
- (CGFloat)eth_sizeForDistanceInMeters:(CGFloat)distanceMeters;

/**
 *  Same as above, in miles.
 *  @param distanceMiles Distance in meters you want to convert in pixels.
 *  @return Distance in pixels that you can directly use to draw a frame for example. This frame will
 *  represent on the map exatly the distance you specified in miles.
 */
- (CGFloat)eth_sizeForDistanceInMiles:(CGFloat)distanceMiles;

/**
 *  Same as above, in feet.
 *  @param distanceFeet Distance in meters you want to convert in pixels.
 *  @return Distance in pixels that you can directly use to draw a frame for example. This frame will
 *  represent on the map exatly the distance you specified in feet.
 */
- (CGFloat)eth_sizeForDistanceInFeet:(CGFloat)distanceFeet;

@end
