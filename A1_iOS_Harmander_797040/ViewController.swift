//
//  ViewController.swift
//  A1_iOS_Harmander_797040
//
//  Created by jimmy on 26/01/21.
//  Copyright © 2021 jimmy. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    @IBOutlet weak var map: MKMapView!
    var userLoc : CLLocation?
    var manager = CLLocationManager()
    var pinCoordinates = [CLLocationCoordinate2D]()
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(controlTap(_:)))
        map.addGestureRecognizer(tapGR)
    }
    @objc func controlTap(_ gesture: UITapGestureRecognizer){
        let touch = gesture.location(in: map)
        let tapLocation = map.convert(touch, toCoordinateFrom: map)
        var title = String()
        if map.annotations.count == 0{
            title = "A"
        }
        else if map.annotations.count == 1{
            title = "B"
        }
        else{
            title = "C"
        }
        if let nearest = map.annotations.closest(to: CLLocation(latitude: tapLocation.latitude, longitude: tapLocation.longitude)){
            map.removeAnnotation(nearest)
            for overlay in map.overlays{
                map.removeOverlay(overlay)
            }
        }
        else{
            if map.annotations.count < 3{
                let annotation  = MKPointAnnotation()
                annotation.title = title
                annotation.coordinate = tapLocation
                map.addAnnotation(annotation)
                if map.annotations.count == 3{
                    let ploygen = MKPolygon(coordinates: map.annotations.map({$0.coordinate}), count: 3)
                    map.addOverlay(ploygen)
                }
            }
            else{
                for overlay in map.overlays{
                    map.removeOverlay(overlay)
                }
                for pin in map.annotations{
                    map.removeAnnotation(pin)
                }
            }
        }
    }
    
    // ******** MAPKIT DELGATES **********
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let _ = overlay as? MKPolygon{
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red
            rendrer.strokeColor = UIColor.green
            rendrer.alpha = 0.5
            return rendrer
        }
        else if let _ = overlay as? MKPolyline{
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.lineWidth = 4
            rendrer.strokeColor = UIColor.purple
            return rendrer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    //******** CLLOCATIOM MANAGER DELGATES **********
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else {return}
        userLoc = loc
        map.region = MKCoordinateRegion(center: userLoc!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    }
    
}
        extension Array where Iterator.Element == MKAnnotation {
            
            func closest(to fixedLocation: CLLocation) -> Iterator.Element? {
                guard !self.isEmpty else { return nil}
                var closestAnnotation: Iterator.Element? = nil
                var smallestDistance: CLLocationDistance = 5000
                for annotation in self {
                    let locationForAnnotation = CLLocation(latitude: annotation.coordinate.latitude, longitude:annotation.coordinate.longitude)
                    let distanceFromUser = fixedLocation.distance(from:locationForAnnotation)
                    if distanceFromUser < smallestDistance {
                        smallestDistance = distanceFromUser
                        closestAnnotation = annotation
                    }
                }
                return closestAnnotation
            }
        }
