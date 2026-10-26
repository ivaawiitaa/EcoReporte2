//
//  FiltroReportesTests.swift
//  EcoReporteTests
//

import XCTest
@testable import EcoReporte

final class FiltroReportesTests: XCTestCase {

    private let reportes: [Reporte] = [
        Reporte(titulo: "Contenedor desbordado", categoria: .basura, descripcion: "Huele mal",
                ubicacion: "Estacionamiento norte", nombreFoto: "a.jpg", estado: .pendiente,
                fechaCreacion: Date(timeIntervalSince1970: 100)),
        Reporte(titulo: "Fuga en bebedero", categoria: .agua, descripcion: "Gotea todo el día",
                ubicacion: "Edificio B", nombreFoto: "b.jpg", estado: .enProceso,
                fechaCreacion: Date(timeIntervalSince1970: 300)),
        Reporte(titulo: "Basura en jardín", categoria: .basura, descripcion: "Envolturas",
                ubicacion: "Jardín central", nombreFoto: "c.jpg", estado: .resuelto,
                fechaCreacion: Date(timeIntervalSince1970: 200))
    ]

    func testSinFiltrosRegresaTodoDelMasRecienteAlMasAntiguo() {
        let resultado = FiltroReportes().aplicar(a: reportes)
        XCTAssertEqual(resultado.map(\.titulo), ["Fuga en bebedero", "Basura en jardín", "Contenedor desbordado"])
    }

    func testFiltraPorCategoria() {
        let filtro = FiltroReportes(categoria: .basura)
        XCTAssertEqual(filtro.aplicar(a: reportes).count, 2)
        XCTAssertTrue(filtro.aplicar(a: reportes).allSatisfy { $0.categoria == .basura })
    }

    func testFiltraPorEstado() {
        let filtro = FiltroReportes(estado: .enProceso)
        XCTAssertEqual(filtro.aplicar(a: reportes).map(\.titulo), ["Fuga en bebedero"])
    }

    func testBuscaTextoSinImportarMayusculasEnTituloYUbicacion() {
        XCTAssertEqual(FiltroReportes(texto: "EDIFICIO").aplicar(a: reportes).count, 1)
        XCTAssertEqual(FiltroReportes(texto: "basura").aplicar(a: reportes).count, 1)
    }

    func testCombinaFiltros() {
        let filtro = FiltroReportes(texto: "jardín", categoria: .basura, estado: .resuelto)
        XCTAssertEqual(filtro.aplicar(a: reportes).map(\.titulo), ["Basura en jardín"])

        let sinCoincidencias = FiltroReportes(categoria: .agua, estado: .resuelto)
        XCTAssertTrue(sinCoincidencias.aplicar(a: reportes).isEmpty)
    }

    func testEstaActivo() {
        XCTAssertFalse(FiltroReportes().estaActivo)
        XCTAssertFalse(FiltroReportes(texto: "   ").estaActivo)
        XCTAssertTrue(FiltroReportes(estado: .pendiente).estaActivo)
    }

    func testResumenCuentaPorEstado() {
        let resumen = ResumenReportes(reportes: reportes)
        XCTAssertEqual(resumen.total, 3)
        XCTAssertEqual(resumen.pendientes, 1)
        XCTAssertEqual(resumen.enProceso, 1)
        XCTAssertEqual(resumen.resueltos, 1)
        XCTAssertEqual(resumen.cantidad(de: .resuelto), 1)
    }
}
