//
//  AlmacenReportes.swift
//  EcoReporte
//
//  Fuente unica de datos de la app. Mantiene los reportes en memoria
//  y los conserva en un archivo JSON dentro de la carpeta Documents.
//

import Foundation
import Observation

enum ErrorAlmacen: LocalizedError {
    case datosInvalidos([ErrorValidacion])

    var errorDescription: String? {
        switch self {
        case .datosInvalidos(let errores):
            return errores.map(\.mensaje).joined(separator: "\n")
        }
    }
}

@Observable
final class AlmacenReportes {
    private(set) var reportes: [Reporte] = []
    //mensaje para la interfaz cuando falla la lectura o escritura
    var mensajeError: String?

    let fotos: AlmacenFotos
    private let archivoReportes: URL

    //las fechas usan el formato por defecto (segundos con decimales) para no perder precision
    private static let codificador: JSONEncoder = {
        let codificador = JSONEncoder()
        codificador.outputFormatting = [.prettyPrinted, .sortedKeys]
        return codificador
    }()

    private static let decodificador = JSONDecoder()

    //la carpeta se puede cambiar para usar una temporal en las pruebas
    init(carpeta: URL = .documentsDirectory) {
        archivoReportes = carpeta.appending(path: "reportes.json")
        fotos = AlmacenFotos(carpeta: carpeta.appending(path: "Fotos", directoryHint: .isDirectory))
        cargar()
    }

    var resumen: ResumenReportes {
        ResumenReportes(reportes: reportes)
    }

    func reporte(con id: UUID) -> Reporte? {
        reportes.first { $0.id == id }
    }

    @discardableResult
    func agregar(_ borrador: BorradorReporte) throws -> Reporte {
        let errores = ValidadorReporte.validar(borrador)
        guard errores.isEmpty, let categoria = borrador.categoria, let foto = borrador.foto else {
            throw ErrorAlmacen.datosInvalidos(errores)
        }

        let nombreFoto = try fotos.guardar(foto)
        let nuevo = Reporte(
            titulo: borrador.titulo.limpio,
            categoria: categoria,
            descripcion: borrador.descripcion.limpio,
            ubicacion: borrador.ubicacion.limpio,
            coordenada: borrador.coordenada,
            nombreFoto: nombreFoto
        )
        reportes.append(nuevo)

        do {
            try guardar()
        } catch {
            //si no se pudo escribir el JSON se deshace todo para no dejar datos a medias
            reportes.removeAll { $0.id == nuevo.id }
            fotos.eliminar(nombre: nombreFoto)
            throw error
        }
        return nuevo
    }

    func cambiarEstado(de id: UUID, a estado: EstadoReporte) {
        guard let indice = reportes.firstIndex(where: { $0.id == id }),
              reportes[indice].estado != estado else { return }
        reportes[indice].estado = estado
        reportes[indice].fechaActualizacion = .now
        guardarMostrandoError()
    }

    func eliminar(_ reporte: Reporte) {
        guard reportes.contains(where: { $0.id == reporte.id }) else { return }
        reportes.removeAll { $0.id == reporte.id }
        fotos.eliminar(nombre: reporte.nombreFoto)
        guardarMostrandoError()
    }

    // MARK: - Persistencia

    private func cargar() {
        guard FileManager.default.fileExists(atPath: archivoReportes.path(percentEncoded: false)) else { return }
        do {
            let datos = try Data(contentsOf: archivoReportes)
            reportes = try Self.decodificador.decode([Reporte].self, from: datos)
        } catch {
            mensajeError = "No se pudieron leer los reportes guardados."
        }
    }

    private func guardar() throws {
        let datos = try Self.codificador.encode(reportes)
        try datos.write(to: archivoReportes, options: .atomic)
    }

    private func guardarMostrandoError() {
        do {
            try guardar()
        } catch {
            mensajeError = "No se pudieron guardar los cambios: \(error.localizedDescription)"
        }
    }
}
