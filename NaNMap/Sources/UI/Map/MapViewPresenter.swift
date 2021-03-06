//
//  MapViewPresenter.swift
//  NaNMap
//
//  Created by 太田龍之介 on 2020/06/15.
//  Copyright © 2020 ryunosuke ota. All rights reserved.
//

protocol MapPresenter {
    func addAnnotation(with info: [Location], at index: Int)
    func addAnnotation(with info: MapSearchLocationObj)
    func removeAnnotation(title: String?)
}

final class MapViewPresenter: MapPresenter {
    weak var view: MapView?
    private let model = MapModel()
    
    init(view: MapView) {
        self.view = view
        model.delegate = self
        model.loadAnnotations()
    }
    
    func addAnnotation(with info: [Location], at index: Int) {
        let title: String = info[index].location
        let subtitle: String = ""
        let longitude: Double = info[index].coordinate.longitude
        let latitude: Double = info[index].coordinate.latitude
        model.addAnnotation(title: title, subtitle: subtitle, coordinate: (longitude, latitude))
    }
    
    func addAnnotation(with info: MapSearchLocationObj) {
        let title: String = info.locationName
        let subtitle: String = info.subInfo
        let longitude: Double = info.longitude
        let latitude: Double = info.latitude
        model.addAnnotation(title: title, subtitle: subtitle, coordinate: (longitude, latitude))
    }
    
    func removeAnnotation(title: String?) {
        model.removeAnnotation(title)
    }
}

extension MapViewPresenter: MapModelDelegate {
    func loadAnnotations(annotations: [AnnotationObj]) {
        view?.loadAnnotations(annotations: annotations)
    }
    
    func addAnnotation(annotation: AnnotationObj) {
        view?.addAnnotation(annotation: annotation)
    }
    
    func reloadMapRegion(at center: (Double, Double)) {
        view?.reloadMapRegion(at: center)
    }
}
