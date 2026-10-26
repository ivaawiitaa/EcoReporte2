//
//  DetalleReporteView.swift
//  EcoReporte
//
//  Muestra toda la informacion de un reporte y permite cambiar su estado.
//

import SwiftUI

struct DetalleReporteView: View {
    @Environment(AlmacenReportes.self) private var almacen
    @Environment(\.dismiss) private var dismiss

    //se guarda solo el id para leer siempre la version mas reciente del almacen
    let reporteID: UUID

    @State private var reporteAEliminar: Reporte?

    var body: some View {
        if let reporte = almacen.reporte(con: reporteID) {
            contenido(de: reporte)
        } else {
            ContentUnavailableView("Reporte no disponible", systemImage: "doc.questionmark")
        }
    }

    private func contenido(de reporte: Reporte) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                encabezado(de: reporte)

                TarjetaDato(titulo: "Ubicación", simbolo: "mappin.and.ellipse", color: .red) {
                    Text(reporte.ubicacion)
                }

                if let coordenada = reporte.coordenada {
                    MapaReporteView(coordenada: coordenada, titulo: reporte.titulo, color: reporte.categoria.color)
                }

                TarjetaDato(titulo: "Descripción", simbolo: "text.alignleft", color: Tema.verde) {
                    Text(reporte.descripcion)
                }

                seguimiento(de: reporte)

                TarjetaDato(titulo: "Fechas", simbolo: "calendar", color: .indigo) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Registrado: \(reporte.fechaCreacion.formatted(date: .abbreviated, time: .shortened))")
                        Text("Actualizado: \(reporte.fechaActualizacion.formatted(date: .abbreviated, time: .shortened))")
                    }
                }

                Button(role: .destructive) {
                    reporteAEliminar = reporte
                } label: {
                    Label("Eliminar reporte", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.red)
            }
            .padding()
        }
        .background(Tema.fondo)
        .navigationTitle("Detalle del reporte")
        .navigationBarTitleDisplayMode(.inline)
        .confirmarEliminacion(de: $reporteAEliminar) { reporteElegido in
            almacen.eliminar(reporteElegido)
            dismiss()
        }
    }

    //foto grande con el titulo encima
    private func encabezado(de reporte: Reporte) -> some View {
        FotoReporteView(nombreFoto: reporte.nombreFoto)
            .frame(height: 300)
            .overlay {
                LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .center, endPoint: .bottom)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    ChipCategoria(categoria: reporte.categoria, sobreFoto: true)
                    Text(reporte.titulo)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .lineLimit(3)
                }
                .padding(18)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
    }

    private func seguimiento(de reporte: Reporte) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Seguimiento")
                .font(.headline)
            HStack(spacing: 10) {
                ForEach(EstadoReporte.allCases) { estado in
                    BotonEstado(estado: estado, seleccionado: reporte.estado == estado) {
                        withAnimation(.snappy) {
                            almacen.cambiarEstado(de: reporte.id, a: estado)
                        }
                    }
                }
            }
            Text("Toca un estado para actualizarlo. El cambio se guarda automáticamente.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .estiloTarjeta()
    }
}

//tarjeta con icono de color, titulo y contenido libre
private struct TarjetaDato<Contenido: View>: View {
    let titulo: String
    let simbolo: String
    let color: Color
    @ViewBuilder let contenido: Contenido

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: simbolo)
                .font(.headline)
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text(titulo)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                contenido
                    .font(.body)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .estiloTarjeta()
    }
}

private struct BotonEstado: View {
    let estado: EstadoReporte
    let seleccionado: Bool
    let accion: () -> Void

    var body: some View {
        Button(action: accion) {
            VStack(spacing: 6) {
                Image(systemName: estado.simbolo)
                    .font(.title3)
                Text(estado.rawValue)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(seleccionado ? .white : estado.color)
            .background(seleccionado ? estado.color : estado.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Marcar como \(estado.rawValue)")
        .accessibilityAddTraits(seleccionado ? .isSelected : [])
    }
}

#Preview {
    let almacen = AlmacenReportes.vistaPrevia
    return NavigationStack {
        DetalleReporteView(reporteID: almacen.reportes[0].id)
    }
    .environment(almacen)
}
