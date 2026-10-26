//
//  ValidadorReporte.swift
//  EcoReporte
//
//  Datos capturados en el formulario y reglas de validacion.
//

import Foundation

//datos del formulario antes de convertirse en un Reporte
struct BorradorReporte: Equatable {
    var titulo = ""
    var categoria: CategoriaReporte?
    var descripcion = ""
    var ubicacion = ""
    //opcional: punto marcado en el mapa
    var coordenada: Coordenada?
    //imagen en formato JPEG lista para guardarse
    var foto: Data?
}

//campos del formulario, sirve para mostrar el error junto al campo correcto
enum CampoReporte {
    case titulo, categoria, descripcion, ubicacion, foto

    var nombre: String {
        switch self {
        case .titulo: return "título"
        case .categoria: return "categoría"
        case .descripcion: return "descripción"
        case .ubicacion: return "ubicación"
        case .foto: return "fotografía"
        }
    }
}

enum ErrorValidacion: Equatable {
    case tituloVacio
    case tituloCorto
    case categoriaFaltante
    case descripcionVacia
    case ubicacionVacia
    case fotoFaltante

    var campo: CampoReporte {
        switch self {
        case .tituloVacio, .tituloCorto: return .titulo
        case .categoriaFaltante: return .categoria
        case .descripcionVacia: return .descripcion
        case .ubicacionVacia: return .ubicacion
        case .fotoFaltante: return .foto
        }
    }

    var mensaje: String {
        switch self {
        case .tituloVacio:
            return "Escribe un título para el reporte."
        case .tituloCorto:
            return "El título debe tener al menos \(ValidadorReporte.longitudMinimaTitulo) caracteres."
        case .categoriaFaltante:
            return "Selecciona una categoría."
        case .descripcionVacia:
            return "Describe brevemente el problema."
        case .ubicacionVacia:
            return "Indica dónde se encuentra el problema."
        case .fotoFaltante:
            return "Agrega una fotografía del problema."
        }
    }
}

enum ValidadorReporte {
    static let longitudMinimaTitulo = 5

    //regresa todos los errores encontrados; un arreglo vacio significa que se puede guardar
    static func validar(_ borrador: BorradorReporte) -> [ErrorValidacion] {
        var errores: [ErrorValidacion] = []

        let titulo = borrador.titulo.limpio
        if titulo.isEmpty {
            errores.append(.tituloVacio)
        } else if titulo.count < longitudMinimaTitulo {
            errores.append(.tituloCorto)
        }
        if borrador.categoria == nil {
            errores.append(.categoriaFaltante)
        }
        if borrador.descripcion.limpio.isEmpty {
            errores.append(.descripcionVacia)
        }
        if borrador.ubicacion.limpio.isEmpty {
            errores.append(.ubicacionVacia)
        }
        if borrador.foto == nil {
            errores.append(.fotoFaltante)
        }
        return errores
    }

    //aviso general del formulario; nombra los campos para que el usuario sepa cuales revisar
    //aunque esten fuera de la pantalla
    static func resumen(de errores: [ErrorValidacion]) -> String {
        let campos = errores.map(\.campo.nombre)
        guard let ultimo = campos.last else { return "" }
        if campos.count == 1 {
            return "Falta: \(ultimo)."
        }
        let lista = campos.dropLast().joined(separator: ", ") + " y " + ultimo
        return "Faltan \(campos.count) datos: \(lista)."
    }
}

extension String {
    //texto sin espacios ni saltos de linea al inicio o al final
    var limpio: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
