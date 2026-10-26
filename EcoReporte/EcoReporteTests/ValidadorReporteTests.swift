//
//  ValidadorReporteTests.swift
//  EcoReporteTests
//

import XCTest
@testable import EcoReporte

final class ValidadorReporteTests: XCTestCase {

    private func borradorCompleto() -> BorradorReporte {
        BorradorReporte(
            titulo: "Basura junto a la cancha",
            categoria: .basura,
            descripcion: "Bolsas acumuladas desde el lunes.",
            ubicacion: "Cancha de básquetbol",
            foto: Data([0xFF, 0xD8, 0xFF])
        )
    }

    func testBorradorCompletoNoTieneErrores() {
        XCTAssertEqual(ValidadorReporte.validar(borradorCompleto()), [])
    }

    func testBorradorVacioReportaTodosLosCampos() {
        let errores = ValidadorReporte.validar(BorradorReporte())
        XCTAssertEqual(errores, [.tituloVacio, .categoriaFaltante, .descripcionVacia, .ubicacionVacia, .fotoFaltante])
    }

    func testSoloEspaciosCuentaComoVacio() {
        var borrador = borradorCompleto()
        borrador.titulo = "    "
        borrador.ubicacion = "\n "
        let errores = ValidadorReporte.validar(borrador)
        XCTAssertTrue(errores.contains(.tituloVacio))
        XCTAssertTrue(errores.contains(.ubicacionVacia))
    }

    func testTituloDemasiadoCorto() {
        var borrador = borradorCompleto()
        borrador.titulo = "Agua"
        XCTAssertEqual(ValidadorReporte.validar(borrador), [.tituloCorto])
    }

    func testSinCategoria() {
        var borrador = borradorCompleto()
        borrador.categoria = nil
        XCTAssertEqual(ValidadorReporte.validar(borrador), [.categoriaFaltante])
    }

    func testSinFotografia() {
        var borrador = borradorCompleto()
        borrador.foto = nil
        XCTAssertEqual(ValidadorReporte.validar(borrador), [.fotoFaltante])
    }

    //mejora tras la prueba con usuario: el aviso dice que campos faltan
    func testResumenNombraLosCamposFaltantes() {
        var borrador = borradorCompleto()
        borrador.titulo = ""
        borrador.descripcion = ""
        borrador.ubicacion = ""
        let resumen = ValidadorReporte.resumen(de: ValidadorReporte.validar(borrador))
        XCTAssertEqual(resumen, "Faltan 3 datos: título, descripción y ubicación.")

        XCTAssertEqual(ValidadorReporte.resumen(de: [.fotoFaltante]), "Falta: fotografía.")
        XCTAssertEqual(ValidadorReporte.resumen(de: []), "")
    }

    func testCadaErrorTieneMensajeYCampo() {
        let errores: [ErrorValidacion] = [.tituloVacio, .tituloCorto, .categoriaFaltante,
                                           .descripcionVacia, .ubicacionVacia, .fotoFaltante]
        for error in errores {
            XCTAssertFalse(error.mensaje.isEmpty)
        }
        XCTAssertEqual(ErrorValidacion.tituloCorto.campo, .titulo)
        XCTAssertEqual(ErrorValidacion.fotoFaltante.campo, .foto)
    }
}
