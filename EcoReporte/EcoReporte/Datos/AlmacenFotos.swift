//
//  AlmacenFotos.swift
//  EcoReporte
//
//  Guarda las fotografias como archivos .jpg dentro de la app.
//

import Foundation

struct AlmacenFotos {
    let carpeta: URL

    //escribe la imagen y regresa el nombre del archivo que se guarda en el reporte
    func guardar(_ datos: Data) throws -> String {
        try FileManager.default.createDirectory(at: carpeta, withIntermediateDirectories: true)
        let nombre = UUID().uuidString + ".jpg"
        try datos.write(to: url(de: nombre), options: .atomic)
        return nombre
    }

    func cargar(nombre: String) -> Data? {
        try? Data(contentsOf: url(de: nombre))
    }

    func existe(nombre: String) -> Bool {
        FileManager.default.fileExists(atPath: url(de: nombre).path(percentEncoded: false))
    }

    func eliminar(nombre: String) {
        try? FileManager.default.removeItem(at: url(de: nombre))
    }

    private func url(de nombre: String) -> URL {
        carpeta.appending(path: nombre)
    }
}
