//
//  MapModel.swift
//  NaNMap
//
//  Created by 太田龍之介 on 2020/06/15.
//  Copyright © 2020 ryunosuke ota. All rights reserved.
//

import RealmSwift

class AnnotationObj: Object {
    @objc dynamic var title = ""
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var annotationID = 0
}

protocol MapModelDelegate: class {
    func loadAnnotations(annotations: [AnnotationObj])
    func addAnnotation(annotation: AnnotationObj)
    func reloadMapRegion(at center: (Double, Double))
}

final class MapModel {
    weak var delegate: MapModelDelegate?
    var regionCenter: (Double, Double)? {
        didSet {
            delegate?.reloadMapRegion(at: regionCenter!)
        }
    }
    
    func loadAnnotations() {
        let realm = try! Realm()
        //try! realm.write { realm.deleteAll() }
        var savedAnnotations = [AnnotationObj]()
        let objs = realm.objects(AnnotationObj.self)
        for obj in objs { savedAnnotations.append(obj) }
        delegate?.loadAnnotations(annotations: savedAnnotations)
    }
    
    private func removeRealmFile() {
        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("note"),
            realmURL.appendingPathExtension("management")
        ]
        for URL in realmURLs {
            do {
                try FileManager.default.removeItem(at: URL)
                print("remove realm file")
            } catch {
                print("remove realm file error")
            }
        }
    }
    
    func addAnnotation(_ title: String, _ coordinate: (Double, Double)) {
        let realm = try! Realm()
        if realm.objects(AnnotationObj.self).filter("title == %@", title).count == 0 {
            let annotation = AnnotationObj()
            if let lastAnnotation = realm.objects(AnnotationObj.self).sorted(byKeyPath: "annotationID").last {
                annotation.annotationID = lastAnnotation.annotationID + 1
            } else {
                annotation.annotationID = 0
            }
            annotation.title = title
            annotation.longitude = coordinate.0
            annotation.latitude = coordinate.1
            try! realm.write {
                realm.add(annotation)
            }
            delegate?.addAnnotation(annotation: annotation)
        }
        self.regionCenter = coordinate
    }
    
    func removeAnnotation(_ title: String?) {
        let realm = try! Realm()
        if let title = title {
            if realm.objects(AnnotationObj.self).filter("title == %@", title).count != 0 {
                let annotation = realm.objects(AnnotationObj.self).filter("title == %@", title)
                try! realm.write {
                    realm.delete(annotation)
                }
            }
        }
    }
}
