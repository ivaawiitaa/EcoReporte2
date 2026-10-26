//
//  FiltroReportes.swift
//  EcoReporte
//
//  Filtros del listado y conteo para el resumen.
//

import Foundation

struct FiltroReportes: Equatable {
    var texto = ""
    var categoria: CategoriaReporte?
    var estado: EstadoReporte?

    var estaActivo: Bool {
        !texto.limpio.isEmpty || categoria != nil || estado != nil
    }

    //regresa los reportes que cumplen todos los filtros, del mas reciente al mas antiguo
    func aplicar(a reportes: [Reporte]) -> [Reporte] {
        let busqueda = texto.limpio
        return reportes
            .filter { categoria == nil || $0.categoria == categoria }
            .filter { estado == nil || $0.estado == estado }
            .filter { reporte in
                busqueda.isEmpty
                    || reporte.titulo.localizedCaseInsensitiveContains(busqueda)
                    || reporte.ubicacion.localizedCaseInsensitiveContains(busqueda)
                    || reporte.descripcion.localizedCaseInsensitiveContains(busqueda)
            }
            .sorted { $0.fechaCreacion > $1.fechaCreacion }
    }
}

struct ResumenReportes: Equatable {
    let total: Int
    let pendientes: Int
    let enProceso: Int
    let resueltos: Int

    init(reportes: [Reporte]) {
        total = reportes.count
        pendientes = reportes.filter { $0.estado == .pendiente }.count
        enProceso = reportes.filter { $0.estado == .enProceso }.count
        resueltos = reportes.filter { $0.estado == .resuelto }.count
    }

    func cantidad(de estado: EstadoReporte) -> Int {
        switch estado {
        case .pendiente: return pendientes
        case .enProceso: return enProceso
        case .resuelto: return resueltos
        }
    }
}
