//
//  Componentes.swift
//  EcoReporte
//
//  Piezas de interfaz reutilizadas en varias pantallas.
//

import SwiftUI

//etiqueta de color con el estado del reporte
struct EtiquetaEstado: View {
    let estado: EstadoReporte

    var body: some View {
        Label(estado.rawValue, systemImage: estado.simbolo)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(estado.color)
            .background(estado.color.opacity(0.15), in: Capsule())
            .accessibilityLabel("Estado: \(estado.rawValue)")
    }
}

//etiqueta de color con la categoria del reporte
struct ChipCategoria: View {
    let categoria: CategoriaReporte
    var sobreFoto = false

    var body: some View {
        Label(categoria.rawValue, systemImage: categoria.simbolo)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(sobreFoto ? .white : categoria.color)
            .background(sobreFoto ? categoria.color.opacity(0.85) : categoria.color.opacity(0.15), in: Capsule())
    }
}

//muestra la fotografia guardada de un reporte; quien la usa define el tamano con .frame
struct FotoReporteView: View {
    @Environment(AlmacenReportes.self) private var almacen
    let nombreFoto: String
    var modo: ContentMode = .fill

    @State private var imagen: UIImage?

    var body: some View {
        Rectangle()
            .fill(Tema.verde.opacity(0.12))
            .overlay {
                if let imagen {
                    Image(uiImage: imagen)
                        .resizable()
                        .aspectRatio(contentMode: modo)
                } else {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(Tema.verde.opacity(0.6))
                }
            }
            .clipped()
            .accessibilityLabel("Fotografía del problema")
            .task(id: nombreFoto) {
                imagen = almacen.fotos.cargar(nombre: nombreFoto).flatMap(UIImage.init(data:))
            }
    }
}

struct FilaReporteView: View {
    let reporte: Reporte

    var body: some View {
        HStack(spacing: 14) {
            FotoReporteView(nombreFoto: reporte.nombreFoto)
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                ChipCategoria(categoria: reporte.categoria)
                Text(reporte.titulo)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Label(reporte.ubicacion, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack {
                    EtiquetaEstado(estado: reporte.estado)
                    Spacer(minLength: 4)
                    Text(reporte.fechaCreacion, format: .relative(presentation: .named))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .estiloTarjeta()
    }
}

//texto rojo que explica como corregir un campo del formulario
struct MensajeError: View {
    let texto: String

    var body: some View {
        Label(texto, systemImage: "exclamationmark.circle.fill")
            .font(.footnote)
            .foregroundStyle(.red)
    }
}

extension View {
    //pide confirmacion antes de borrar; se usa en el listado y en el detalle
    func confirmarEliminacion(
        de reporte: Binding<Reporte?>,
        alConfirmar: @escaping (Reporte) -> Void
    ) -> some View {
        alert(
            "¿Eliminar este reporte?",
            isPresented: Binding(
                get: { reporte.wrappedValue != nil },
                set: { if !$0 { reporte.wrappedValue = nil } }
            ),
            presenting: reporte.wrappedValue
        ) { reporteElegido in
            Button("Eliminar", role: .destructive) { alConfirmar(reporteElegido) }
            Button("Cancelar", role: .cancel) {}
        } message: { reporteElegido in
            Text("Se borrará «\(reporteElegido.titulo)» y su fotografía. Esta acción no se puede deshacer.")
        }
    }

    //muestra los errores de lectura o escritura del almacen
    func alertaError(de almacen: AlmacenReportes) -> some View {
        alert(
            "Ocurrió un problema",
            isPresented: Binding(
                get: { almacen.mensajeError != nil },
                set: { if !$0 { almacen.mensajeError = nil } }
            )
        ) {
            Button("Aceptar", role: .cancel) {}
        } message: {
            Text(almacen.mensajeError ?? "")
        }
    }
}

extension AlmacenReportes {
    //almacen con datos de ejemplo en una carpeta temporal, solo para los Previews de Xcode
    static var vistaPrevia: AlmacenReportes {
        let carpeta = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let almacen = AlmacenReportes(carpeta: carpeta)
        almacen.cargarEjemplos()
        if let primero = almacen.reportes.first {
            almacen.cambiarEstado(de: primero.id, a: .enProceso)
        }
        return almacen
    }
}
