//
//  ViewController.swift
//  PW_assignment
//
//  Created by Varun Sharma on 19/04/24.
//

import UIKit
import MapKit


//Custom Annoatation on Map
class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    private let pathCoordinates: [CLLocationCoordinate2D]
    
    init(coordinates: [CLLocationCoordinate2D], title: String?) {
        self.coordinate = coordinates.first ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        self.title = title
        self.pathCoordinates = coordinates
        super.init()
    }
}

// Custom View for Annoation on Map
public class CustomAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.image = UIImage(named: "delivery")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ViewController: UIViewController {
    var errorMessage: String?
    var startLatitude: String = "0"
    var startLongitude: String = "0.0"
    var endLatitude: String = "0.0"
    var endLongitude: String = "0.0"
    var timedVariable: Int = 1
    
    
    let ordertitle: UILabel = {
        let order = UILabel()
        order.text = "Order is on the way 🤟🏻"
        order.font = .systemFont(ofSize: 24,weight: .bold)
        order.textColor = .white
        order.translatesAutoresizingMaskIntoConstraints = false
        return order
    }()
    
    let subtitle: UILabel = {
        let order = UILabel()
        order.text = "Reaching to you in"+"0"+"seconds"
        order.font = .systemFont(ofSize: 18)
        order.textColor = .white
        order.translatesAutoresizingMaskIntoConstraints = false
        //order.font.withSize(23)
        return order
    }()
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    let panel: UIView = {
        let panelView = UIView()
        panelView.backgroundColor = UIColor.white
        let img = UIImage(named: "delivery")
        let imgview = UIImageView(frame: CGRect(x: 20, y: 20, width: 50, height: 50))
        imgview.image = img
        
        let deliveryBoy = UILabel(frame: CGRect(x: 80, y:0, width: 250, height: 100))
        deliveryBoy.text = "I'm name, your delivery partner"
        deliveryBoy.numberOfLines = 0
        deliveryBoy.font = .systemFont(ofSize: 20, weight: .regular)
        deliveryBoy.tag = 100
        
        let subheading = UILabel(frame: CGRect(x: 60, y:50, width: 300, height: 100))
        subheading.text = "I'm on my way to your location"
        subheading.textColor = .systemGreen.withAlphaComponent(1.2)
        subheading.font = .systemFont(ofSize: 18, weight: .semibold)
        
        let foodImage = UIImage(named: "food")
        let foodview = UIImageView(frame: CGRect(x: 100, y: 120, width: 50, height: 50))
        foodview.image = foodImage
        
        let foodText = UILabel(frame: CGRect(x: 160, y:100, width: 250, height: 100))
        foodText.text = "Random food"
        foodText.font = .systemFont(ofSize: 20, weight: .semibold)
        foodText.tag = 200
        
        panelView.addSubview(imgview)
        panelView.addSubview(deliveryBoy)
        panelView.addSubview(subheading)
        panelView.addSubview(foodview)
        panelView.addSubview(foodText)
        panelView.translatesAutoresizingMaskIntoConstraints = false
        return panelView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: { [self] in
            configureMap()
        })
     
        fetchDataFromAPI()
    }
    
    //Implementation of API Fetching
    func fetchDataFromAPI() {
        ViewModel().fetchData() { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let dataModel):
                DispatchQueue.main.async { [self] in
                    self.subtitle.text = "Reaching to you in "+String(dataModel[0].time)+" seconds"
                    if let label = self.panel.viewWithTag(100) as? UILabel {
                        label.text = "I'm "+dataModel[0].deliveryboy+", your delivery partner"
                    }
                    if let foodLabel = self.panel.viewWithTag(200) as? UILabel {
                        foodLabel.text = dataModel[0].foodname
                        print(dataModel[0].foodname)
                    }
                    
                    self.startLatitude = dataModel[0].startlat
                    self.startLongitude = dataModel[0].startlong
                    self.endLatitude = dataModel[0].endlat
                    self.endLongitude = dataModel[0].endlong
                    self.timedVariable = dataModel[0].time
                }
                
            case .failure(let error):
                self.dataFetchFailed(error: error)
            }
        }
    }
    
    func dataFetchFailed(error: Error) {
        errorMessage = error.localizedDescription
        // Handle the error
        print("Error fetching data: \(errorMessage ?? "Unknown error")")
    }
    
    private func setupUI() {
        view.addSubview(ordertitle)
        view.addSubview(subtitle)
        view.addSubview(mapView)
        view.addSubview(panel)
        view.backgroundColor = .systemGreen.withAlphaComponent(0.9)
        
        NSLayoutConstraint.activate([
            
            ordertitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            ordertitle.heightAnchor.constraint(equalToConstant: 40),
            ordertitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            subtitle.heightAnchor.constraint(equalToConstant: 40),
            subtitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitle.leadingAnchor.constraint(equalTo: ordertitle.leadingAnchor),
            
            panel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 0),
            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            panel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -250),
        ])
        
    }
    
    // Main configurations of Map in MapKit
    private func configureMap() {
        mapView.delegate = self
        
        dynamic let pathCoordinates = [
            CLLocationCoordinate2D(latitude: Double(startLatitude)!, longitude: Double(startLongitude)!),
            CLLocationCoordinate2D(latitude: Double(endLatitude)!, longitude: Double(endLongitude)!),
        ]
        
        let annotation = CustomAnnotation(coordinates: pathCoordinates, title: "Moving Pins")
        mapView.addAnnotation(annotation)
        
        let regionRadius: CLLocationDistance = 350
        let region = MKCoordinateRegion(center: pathCoordinates.first!, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pathCoordinates[0]))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: pathCoordinates[1]))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let route = response?.routes.first else {
                if let error = error {
                    print("Error getting directions: \(error.localizedDescription)")
                }
                return
            }
            self.mapView.addOverlay(route.polyline)
            self.addPinAndFollowRoute(route: route, duration: TimeInterval(self.timedVariable))
        }
        mapView.setRegion(region, animated: true)
    }
    
    //Path following algorithm for deliveryboy
    func addPinAndFollowRoute(route: MKRoute, duration: TimeInterval) {
        let pin = MKPointAnnotation()
        pin.coordinate = route.polyline.coordinate
        mapView.addAnnotation(pin)
        
        var elapsedTime: TimeInterval = 0.0
        let totalDuration = duration
        let pointCount = route.polyline.pointCount
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            elapsedTime += 0.01
            
            if elapsedTime >= totalDuration {
                self.showAlert()
                self.ordertitle.text = "Order Delivered!! 🎉🎉 "
                timer.invalidate()
                return
            }
            
            let fraction = elapsedTime / totalDuration
            let index = Int(fraction * Double(pointCount - 1))
            
            if index < pointCount - 1 {
                let startCoordinate = route.polyline.points()[index].coordinate
                let endCoordinate = route.polyline.points()[index + 1].coordinate
                let interpolatedCoordinate = self.interpolateCoordinate(startCoordinate, endCoordinate, fraction)
                
                UIView.animate(withDuration: 0.01) { // Decreased animation duration for smoother movement
                    pin.coordinate = interpolatedCoordinate
                }
            }
        }
    }

    func interpolateCoordinate(_ start: CLLocationCoordinate2D, _ end: CLLocationCoordinate2D, _ fraction: Double) -> CLLocationCoordinate2D {
        let lat = start.latitude + (end.latitude - start.latitude) * fraction
        let lon = start.longitude + (end.longitude - start.longitude) * fraction
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    //Order Delivered Message
    func showAlert() {
          let alert = UIAlertController(title: "Order Delivered", message: "Enjoy the meal", preferredStyle: .alert)
          let okAction = UIAlertAction(title: "OK", style: .default) { _ in
              // Handle OK action if needed
          }
          alert.addAction(okAction)
          present(alert, animated: true, completion: nil)
      }

}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CustomAnnotation else {
            return nil
        }
        let identifier = "CustomAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
}

extension ViewController {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.systemTeal
            renderer.lineWidth = 6
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
