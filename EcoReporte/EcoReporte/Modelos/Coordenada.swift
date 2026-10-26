//
//  Coordenada.swift
//  EcoReporte
//
//  Punto en el mapa donde esta el problema. Es opcional: la ubicacion
//  en texto sigue siendo el dato obligatorio del reporte.
//

import Foundation
import CoreLocation

struct Coordenada: Codable, Equatable {
    var latitud: Double
    var longitud: Double

    //centro del campus del Tec Laguna, entre sus edificios (OpenStreetMap)
    static let campusTec = Coordenada(latitud: 25.5332, longitud: -103.4356)
}

extension Coordenada {
    init(_ coordenada: CLLocationCoordinate2D) {
        self.init(latitud: coordenada.latitude, longitud: coordenada.longitude)
    }

    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
    }
}
