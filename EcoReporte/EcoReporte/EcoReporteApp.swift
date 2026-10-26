//
//  EcoReporteApp.swift
//  EcoReporte
//

import SwiftUI

@main
struct EcoReporteApp: App {
    //se crea una sola vez y se comparte con todas las pantallas
    @State private var almacen = AlmacenReportes()

    var body: some Scene {
        WindowGroup {
            ListaReportesView()
                .environment(almacen)
                .tint(Tema.verde)
        }
    }
}
