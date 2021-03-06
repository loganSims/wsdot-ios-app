/* Copyright (c) 2016 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

#import <GoogleMaps/GoogleMaps.h>

#import "Algo/GMUClusterAlgorithm.h"
#import "GMUClusterItem.h"
#import "View/GMUClusterRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@class GMUClusterManager;

/** Delegate for events on GMUClusterManager. */
@protocol GMUClusterManagerDelegate<NSObject>

@optional

/** Called when the user taps on a cluster marker. */
- (void)clusterManager:(GMUClusterManager *)clusterManager didTapCluster:(id<GMUCluster>)cluster;

/** Called when the user taps on a cluster item marker. */
- (void)clusterManager:(GMUClusterManager *)clusterManager
     didTapClusterItem:(id<GMUClusterItem>)clusterItem;

@end

/**
 * This class groups many items on a map based on zoom level.
 * Cluster items should be added to the map via this class.
 */
@interface GMUClusterManager : NSObject<GMSMapViewDelegate>

/** Initializer with the |mapView|, |algorithm| and |renderer|. */
- (instancetype)initWithMap:(GMSMapView *)mapView
                  algorithm:(id<GMUClusterAlgorithm>)algorithm
                   renderer:(id<GMUClusterRenderer>)renderer;

/** Gets the clustering algorithm. */
@property(nonatomic, readonly) id<GMUClusterAlgorithm> algorithm;

/**
 * GMUClusterManager |delegate|.
 * To set it use the setDelegate:mapDelegate: method.
 */
@property(nonatomic, readonly, weak, nullable) id<GMUClusterManagerDelegate> delegate;

/**
 * The GMSMapViewDelegate delegate that map events are being forwarded to.
 * To set it use the setDelegate:mapDelegate: method.
 */
@property(nonatomic, readonly, weak, nullable) id<GMSMapViewDelegate> mapDelegate;

/**
 * Sets GMUClusterManagerDelegate |delegate| and optionally
 * provides a |mapDelegate| to listen to forwarded map events.
 *
 * NOTES: This method changes the |delegate| property of the
 * managed |mapView| to this object, intercepting events that
 * the GMUClusterManager wants to action or rebroadcast
 * to the GMUClusterManagerDelegate. Any remaining events are
 * then forwarded to the new |mapDelegate| provided here.
 *
 * EXAMPLE: [clusterManager setDelegate:self mapDelegate:_map.delegate];
 * In this example self will receive type-safe GMUClusterManagerDelegate
 * events and other map events will be forwarded to the current map delegate.
 */
- (void)setDelegate:(id<GMUClusterManagerDelegate> _Nullable)delegate
        mapDelegate:(id<GMSMapViewDelegate> _Nullable)mapDelegate;

/** Adds a cluster item to the collection. */
- (void)addItem:(id<GMUClusterItem>)item;

/** Adds multiple cluster items to the collection. */
- (void)addItems:(NSArray<id<GMUClusterItem>> *)items;

/** Removes a cluster item from the collection. */
- (void)removeItem:(id<GMUClusterItem>)item;

/** Removes all items from the collection. */
- (void)clearItems;

/**
 * Called to arrange items into groups.
 * - This method will be automatically invoked when the map's zoom level changes.
 * - Manually invoke this method when new items have been added to rearrange items.
 */
- (void)cluster;

@end


NS_ASSUME_NONNULL_END

