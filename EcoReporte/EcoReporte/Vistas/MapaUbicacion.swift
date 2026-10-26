//
//  MapaUbicacion.swift
//  EcoReporte
//
//  Mapas del campus: uno para marcar el lugar del problema en el formulario
//  y otro para mostrarlo en el detalle del reporte.
//

import SwiftUI
import MapKit

extension Coordenada {
    func region(delta: CLLocationDegrees = 0.008) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: clCoordinate,
            span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        )
    }
}

//mapa del campus donde un toque marca el lugar del problema
struct SelectorUbicacionMapa: View {
    @Binding var coordenada: Coordenada?
    @State private var posicion: MapCameraPosition = .region(Coordenada.campusTec.region())

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MapReader { proxy in
                Map(position: $posicion) {
                    if let coordenada {
                        Marker("Problema", systemImage: "exclamationmark.triangle.fill",
                               coordinate: coordenada.clCoordinate)
                            .tint(.red)
                    }
                }
                .onTapGesture { punto in
                    if let lugar = proxy.convert(punto, from: .local) {
                        withAnimation(.snappy) { coordenada = Coordenada(lugar) }
                    }
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: Tema.radio))
            .accessibilityLabel("Mapa del campus. Toca para marcar dónde está el problema.")

            HStack {
                Label(coordenada == nil ? "Toca el mapa para marcar el lugar" : "Lugar marcado en el mapa",
                      systemImage: coordenada == nil ? "hand.tap" : "mappin.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(coordenada == nil ? Color.secondary : Tema.verde)
                Spacer()
                if coordenada != nil {
                    Button("Quitar", role: .destructive) {
                        withAnimation(.snappy) { coordenada = nil }
                    }
                    .font(.footnote)
                    .buttonStyle(.borderless)
                }
            }
        }
    }
}

//mapa fijo con el lugar del reporte y acceso a la app Mapas
struct MapaReporteView: View {
    let coordenada: Coordenada
    let titulo: String
    let color: Color

    var body: some View {
        Map(initialPosition: .region(coordenada.region(delta: 0.004))) {
            Marker(titulo, coordinate: coordenada.clCoordinate)
                .tint(color)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: Tema.radio))
        .overlay(alignment: .bottomTrailing) {
            Button(action: abrirEnMapas) {
                Label("Abrir en Mapas", systemImage: "map")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(10)
        }
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    private func abrirEnMapas() {
        let lugar = MKMapItem(placemark: MKPlacemark(coordinate: coordenada.clCoordinate))
        lugar.name = titulo
        lugar.openInMaps()
    }
}

#Preview {
    VStack(spacing: 20) {
        SelectorUbicacionMapa(coordenada: .constant(Coordenada.campusTec))
        MapaReporteView(coordenada: .campusTec, titulo: "Tubo de agua goteando", color: .cyan)
    }
    .padding()
}
