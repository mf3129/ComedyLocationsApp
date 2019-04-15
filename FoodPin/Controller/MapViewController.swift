//
//  MapViewController.swift
//  FoodPin
//
//  Created by Makan Fofana on 1/22/19.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var restaurant: RestaurantMO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale = MKScaleView(mapView: mapView)
        scale.scaleVisibility = .visible // always visible
        view.addSubview(scale)
        
        //Customizing the Map View
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        
        //Converting the Address To Coordinate and Annotate On The Map
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(restaurant.location ?? "", completionHandler: { placemarks, error in
        if let error = error {
            print(error)
            return
        }
        
        if let placemarks = placemarks {
            //Obtaining the First Placemark
            let placemark = placemarks[0]
            
            //Adding The Annotation
            let annotation = MKPointAnnotation()
            annotation.title = self.restaurant.name
            annotation.subtitle = self.restaurant.type
            
            if let location = placemark.location {
               annotation.coordinate = location.coordinate
                
                self.mapView.showAnnotations([annotation], animated: true)
                self.mapView.showAnnotations([annotation], animated: true)
       
            }
          }
        })
    }
    
    
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
        {
            let identifier = "MyMarker"
            
            if annotation.isKind(of: MKUserLocation.self) {
                return nil
            }
            
            var annotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            annotationView?.glyphText = "🎤"
            annotationView?.markerTintColor = UIColor.orange
            
            return annotationView
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


