//
//  DatosEjemplo.swift
//  EcoReporte
//
//  Reportes de ejemplo con fotos tomadas en el campus (guardadas en Assets.xcassets).
//  Se usan en el boton "Cargar ejemplos del campus" y en los Previews de Xcode.
//

import UIKit

enum DatosEjemplo {
    static func borradores() -> [BorradorReporte] {
        [
            BorradorReporte(titulo: "Basura mal separada en contenedor", categoria: .basura,
                            descripcion: "Envolturas de frituras en el compartimento de plásticos y basura sobre la tapa.",
                            ubicacion: "Contenedor de reciclaje",
                            coordenada: cerca(0.0013, -0.0001), foto: foto("contenedor_reciclaje")),
            BorradorReporte(titulo: "Cesto improvisado sin tapa", categoria: .basura,
                            descripcion: "Se usa un cesto de ropa como bote de basura junto a la pared.",
                            ubicacion: "Área de terracería",
                            coordenada: cerca(-0.0006, -0.0007), foto: foto("bote_improvisado")),
            BorradorReporte(titulo: "Tambo sin identificar", categoria: .otro,
                            descripcion: "Tambo con señal de prohibido y sin indicar qué contiene.",
                            ubicacion: "Área de terracería",
                            coordenada: cerca(-0.0007, -0.0005), foto: foto("tambo_residuos")),
            BorradorReporte(titulo: "Tubo de agua goteando", categoria: .agua,
                            descripcion: "Tubo de PVC sin llave que gotea; se puso una cubeta para juntar el agua.",
                            ubicacion: "Pasillo junto a la columna",
                            coordenada: cerca(0.0009, 0.0006), foto: foto("fuga_tubo_agua")),
            BorradorReporte(titulo: "Vehículo con motor encendido", categoria: .aire,
                            descripcion: "Vehículo estacionado con el motor prendido.",
                            ubicacion: "Estacionamiento",
                            coordenada: cerca(-0.0014, 0.0), foto: foto("vehiculo_estacionamiento"))
        ]
    }

    //puntos aproximados alrededor del centro del campus; ajustarlos al lugar real de cada foto
    private static func cerca(_ deltaLatitud: Double, _ deltaLongitud: Double) -> Coordenada {
        Coordenada(latitud: Coordenada.campusTec.latitud + deltaLatitud,
                   longitud: Coordenada.campusTec.longitud + deltaLongitud)
    }

    private static func foto(_ nombre: String) -> Data? {
        UIImage(named: nombre)?.jpegData(compressionQuality: 0.8)
    }
}

extension AlmacenReportes {
    //agrega los reportes de ejemplo y regresa cuantos se guardaron
    @discardableResult
    func cargarEjemplos() -> Int {
        var agregados = 0
        for borrador in DatosEjemplo.borradores() {
            do {
                try agregar(borrador)
                agregados += 1
            } catch {
                mensajeError = "No se pudo cargar un ejemplo: \(error.localizedDescription)"
            }
        }
        return agregados
    }
}
