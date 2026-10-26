//
//  ResumenView.swift
//  EcoReporte
//
//  Encabezado con el total y conteo por estado. Tocar una tarjeta filtra el listado.
//

import SwiftUI

struct ResumenView: View {
    let resumen: ResumenReportes
    @Binding var estadoSeleccionado: EstadoReporte?

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cuidemos nuestro campus")
                        .font(.title3.bold())
                    Text(resumen.total == 1 ? "1 reporte registrado" : "\(resumen.total) reportes registrados")
                        .font(.subheadline)
                        .opacity(0.9)
                }
                Spacer()
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 48))
                    .symbolRenderingMode(.hierarchical)
            }
            .foregroundStyle(.white)
            .padding(18)
            .background(Tema.degradado, in: RoundedRectangle(cornerRadius: 20))
            .accessibilityElement(children: .combine)

            HStack(spacing: 10) {
                ForEach(EstadoReporte.allCases) { estado in
                    Button {
                        withAnimation(.snappy) {
                            estadoSeleccionado = estadoSeleccionado == estado ? nil : estado
                        }
                    } label: {
                        TarjetaEstado(
                            estado: estado,
                            cantidad: resumen.cantidad(de: estado),
                            seleccionada: estadoSeleccionado == estado
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct TarjetaEstado: View {
    let estado: EstadoReporte
    let cantidad: Int
    let seleccionada: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: estado.simbolo)
                .font(.headline)
                .frame(width: 30, height: 30)
                .background(seleccionada ? Color.white.opacity(0.25) : estado.color.opacity(0.15), in: Circle())
            Text("\(cantidad)")
                .font(.title2.bold())
                .contentTransition(.numericText())
            Text(estado.rawValue)
                .font(.caption.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(seleccionada ? .white : estado.color)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            seleccionada ? AnyShapeStyle(estado.color) : AnyShapeStyle(Tema.fondoTarjeta),
            in: RoundedRectangle(cornerRadius: Tema.radio)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(estado.rawValue): \(cantidad)")
        .accessibilityHint(seleccionada ? "Toca para quitar el filtro" : "Toca para ver solo estos reportes")
        .accessibilityAddTraits(seleccionada ? .isSelected : [])
    }
}

#Preview {
    ResumenView(
        resumen: AlmacenReportes.vistaPrevia.resumen,
        estadoSeleccionado: .constant(.pendiente)
    )
    .padding()
    .background(Tema.fondo)
}
