//
//  AlmacenReportesTests.swift
//  EcoReporteTests
//
//  Cada prueba usa una carpeta temporal nueva. Crear un segundo
//  AlmacenReportes sobre la misma carpeta simula cerrar y abrir la app.
//

import XCTest
@testable import EcoReporte

final class AlmacenReportesTests: XCTestCase {

    private var carpeta: URL!

    override func setUpWithError() throws {
        carpeta = FileManager.default.temporaryDirectory.appending(path: "EcoReporteTests-\(UUID().uuidString)")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: carpeta)
    }

    private func borrador(_ titulo: String = "Fuga en bebedero") -> BorradorReporte {
        BorradorReporte(
            titulo: titulo,
            categoria: .agua,
            descripcion: "Gotea todo el día.",
            ubicacion: "Edificio B",
            foto: Data([0xFF, 0xD8, 0xFF, 0xE0])
        )
    }

    func testAgregarGuardaReporteYFotografia() throws {
        let almacen = AlmacenReportes(carpeta: carpeta)
        let reporte = try almacen.agregar(borrador("  Fuga en bebedero  "))

        XCTAssertEqual(almacen.reportes.count, 1)
        XCTAssertEqual(reporte.titulo, "Fuga en bebedero", "El título se guarda sin espacios sobrantes")
        XCTAssertEqual(reporte.estado, .pendiente)
        XCTAssertTrue(almacen.fotos.existe(nombre: reporte.nombreFoto))
    }

    func testNoPermiteGuardarBorradorIncompleto() {
        let almacen = AlmacenReportes(carpeta: carpeta)
        var incompleto = borrador()
        incompleto.categoria = nil

        XCTAssertThrowsError(try almacen.agregar(incompleto))
        XCTAssertTrue(almacen.reportes.isEmpty)
    }

    func testReportesYFotoSeConservanAlReiniciar() throws {
        let original = try AlmacenReportes(carpeta: carpeta).agregar(borrador())

        let reabierto = AlmacenReportes(carpeta: carpeta)
        XCTAssertEqual(reabierto.reportes, [original])
        XCTAssertEqual(reabierto.fotos.cargar(nombre: original.nombreFoto), Data([0xFF, 0xD8, 0xFF, 0xE0]))
    }

    func testCambioDeEstadoSeConservaAlReiniciar() throws {
        let almacen = AlmacenReportes(carpeta: carpeta)
        let reporte = try almacen.agregar(borrador())

        almacen.cambiarEstado(de: reporte.id, a: .resuelto)
        XCTAssertEqual(almacen.resumen.resueltos, 1)
        XCTAssertEqual(almacen.resumen.pendientes, 0)

        let reabierto = AlmacenReportes(carpeta: carpeta)
        XCTAssertEqual(reabierto.reporte(con: reporte.id)?.estado, .resuelto)
        XCTAssertGreaterThanOrEqual(reabierto.reporte(con: reporte.id)!.fechaActualizacion, reporte.fechaCreacion)
    }

    func testEliminarBorraReporteYFotoTrasReiniciar() throws {
        let almacen = AlmacenReportes(carpeta: carpeta)
        let primero = try almacen.agregar(borrador("Reporte uno"))
        let segundo = try almacen.agregar(borrador("Reporte dos"))

        almacen.eliminar(primero)

        let reabierto = AlmacenReportes(carpeta: carpeta)
        XCTAssertEqual(reabierto.reportes.map(\.id), [segundo.id])
        XCTAssertFalse(reabierto.fotos.existe(nombre: primero.nombreFoto))
        XCTAssertTrue(reabierto.fotos.existe(nombre: segundo.nombreFoto))
    }

    func testReiniciarVariasVecesNoDuplicaReportes() throws {
        let almacen = AlmacenReportes(carpeta: carpeta)
        try almacen.agregar(borrador("Reporte uno"))
        try almacen.agregar(borrador("Reporte dos"))

        for _ in 1...3 {
            let reabierto = AlmacenReportes(carpeta: carpeta)
            XCTAssertEqual(reabierto.reportes.count, 2)
            XCTAssertEqual(Set(reabierto.reportes.map(\.id)).count, 2)
        }
    }

    func testCargarEjemplosUsaLasFotosDeAssetsYSeConserva() {
        let almacen = AlmacenReportes(carpeta: carpeta)
        XCTAssertEqual(almacen.cargarEjemplos(), DatosEjemplo.borradores().count)

        let reabierto = AlmacenReportes(carpeta: carpeta)
        XCTAssertEqual(reabierto.reportes.count, 5)
        XCTAssertTrue(reabierto.reportes.allSatisfy { reabierto.fotos.existe(nombre: $0.nombreFoto) })
    }

    func testCoordenadaDelMapaSeConservaAlReiniciar() throws {
        var conMapa = borrador()
        conMapa.coordenada = Coordenada(latitud: 25.5344, longitud: -103.4341)
        let reporte = try AlmacenReportes(carpeta: carpeta).agregar(conMapa)

        let reabierto = AlmacenReportes(carpeta: carpeta)
        XCTAssertEqual(reabierto.reporte(con: reporte.id)?.coordenada, conMapa.coordenada)
    }

    //los reportes guardados antes de agregar el mapa no tienen "coordenada" y deben seguir cargando
    func testCargaReportesGuardadosSinCoordenada() throws {
        try FileManager.default.createDirectory(at: carpeta, withIntermediateDirectories: true)
        let jsonAnterior = """
        [{"id":"\(UUID().uuidString)","titulo":"Fuga en bebedero","categoria":"Agua y fugas",
          "descripcion":"Gotea","ubicacion":"Edificio B","nombreFoto":"a.jpg","estado":"Pendiente",
          "fechaCreacion":0,"fechaActualizacion":0}]
        """
        try Data(jsonAnterior.utf8).write(to: carpeta.appending(path: "reportes.json"))

        let almacen = AlmacenReportes(carpeta: carpeta)
        XCTAssertEqual(almacen.reportes.count, 1)
        XCTAssertNil(almacen.reportes.first?.coordenada)
        XCTAssertNil(almacen.mensajeError)
    }

    func testEliminarDosVecesNoAfectaOtrosReportes() throws {
        let almacen = AlmacenReportes(carpeta: carpeta)
        let primero = try almacen.agregar(borrador("Reporte uno"))
        try almacen.agregar(borrador("Reporte dos"))

        almacen.eliminar(primero)
        almacen.eliminar(primero)

        XCTAssertEqual(AlmacenReportes(carpeta: carpeta).reportes.count, 1)
    }
}
