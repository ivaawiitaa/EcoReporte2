//
//  Reporte.swift
//  EcoReporte
//
//  Modelo principal: un reporte de un problema ambiental.
//

import Foundation

//categorias disponibles para clasificar un reporte
enum CategoriaReporte: String, Codable, CaseIterable, Identifiable {
    case basura = "Basura y residuos"
    case agua = "Agua y fugas"
    case areasVerdes = "Áreas verdes"
    case aire = "Contaminación del aire"
    case ruido = "Ruido"
    case energia = "Energía"
    case otro = "Otro"

    var id: String { rawValue }

    var simbolo: String {
        switch self {
        case .basura: return "trash"
        case .agua: return "drop"
        case .areasVerdes: return "leaf"
        case .aire: return "aqi.medium"
        case .ruido: return "speaker.wave.3"
        case .energia: return "bolt"
        case .otro: return "questionmark.circle"
        }
    }
}

//etapas de seguimiento de un reporte
enum EstadoReporte: String, Codable, CaseIterable, Identifiable {
    case pendiente = "Pendiente"
    case enProceso = "En proceso"
    case resuelto = "Resuelto"

    var id: String { rawValue }

    var simbolo: String {
        switch self {
        case .pendiente: return "exclamationmark.circle"
        case .enProceso: return "clock.arrow.circlepath"
        case .resuelto: return "checkmark.circle"
        }
    }
}

struct Reporte: Identifiable, Codable, Equatable {
    let id: UUID
    var titulo: String
    var categoria: CategoriaReporte
    var descripcion: String
    var ubicacion: String
    //punto marcado en el mapa; los reportes guardados antes de esta version no lo tienen
    var coordenada: Coordenada?
    //nombre del archivo .jpg guardado en la carpeta de fotos
    var nombreFoto: String
    var estado: EstadoReporte
    let fechaCreacion: Date
    var fechaActualizacion: Date

    init(
        id: UUID = UUID(),
        titulo: String,
        categoria: CategoriaReporte,
        descripcion: String,
        ubicacion: String,
        coordenada: Coordenada? = nil,
        nombreFoto: String,
        estado: EstadoReporte = .pendiente,
        fechaCreacion: Date = .now
    ) {
        self.id = id
        self.titulo = titulo
        self.categoria = categoria
        self.descripcion = descripcion
        self.ubicacion = ubicacion
        self.coordenada = coordenada
        self.nombreFoto = nombreFoto
        self.estado = estado
        self.fechaCreacion = fechaCreacion
        self.fechaActualizacion = fechaCreacion
    }
}
