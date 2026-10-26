//
//  ListaReportesView.swift
//  EcoReporte
//
//  Pantalla principal: resumen, busqueda, filtros y listado de reportes.
//

import SwiftUI

struct ListaReportesView: View {
    @Environment(AlmacenReportes.self) private var almacen

    @State private var filtro = FiltroReportes()
    @State private var mostrandoFormulario = false
    @State private var reporteAEliminar: Reporte?

    private var reportesFiltrados: [Reporte] {
        filtro.aplicar(a: almacen.reportes)
    }

    var body: some View {
        NavigationStack {
            List {
                ResumenView(resumen: almacen.resumen, estadoSeleccionado: $filtro.estado)
                    .estiloFila()

                encabezadoListado
                    .estiloFila()

                if reportesFiltrados.isEmpty {
                    estadoVacio
                        .estiloFila()
                } else {
                    ForEach(reportesFiltrados) { reporte in
                        //el NavigationLink invisible evita la flecha y el fondo gris de la fila
                        ZStack {
                            NavigationLink(value: reporte.id) { EmptyView() }
                                .opacity(0)
                            FilaReporteView(reporte: reporte)
                        }
                        .estiloFila()
                        .swipeActions {
                            Button {
                                reporteAEliminar = reporte
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Tema.fondo)
            .animation(.snappy, value: reportesFiltrados)
            .navigationTitle("EcoReporte")
            .navigationDestination(for: UUID.self) { id in
                DetalleReporteView(reporteID: id)
            }
            .searchable(text: $filtro.texto, prompt: "Buscar por título, lugar o descripción")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    MenuFiltros(filtro: $filtro)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        mostrandoFormulario = true
                    } label: {
                        Label("Nuevo reporte", systemImage: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $mostrandoFormulario) {
                FormularioReporteView()
            }
            .confirmarEliminacion(de: $reporteAEliminar) { reporte in
                almacen.eliminar(reporte)
            }
            .alertaError(de: almacen)
        }
    }

    private var encabezadoListado: some View {
        HStack {
            Text(filtro.estaActivo
                 ? "Mostrando \(reportesFiltrados.count) de \(almacen.reportes.count)"
                 : "Reportes recientes")
                .font(.headline)
            Spacer()
            if filtro.estaActivo {
                Button {
                    withAnimation(.snappy) { filtro = FiltroReportes() }
                } label: {
                    Label("Quitar filtros", systemImage: "xmark.circle.fill")
                        .font(.footnote.weight(.semibold))
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private var estadoVacio: some View {
        if almacen.reportes.isEmpty {
            ContentUnavailableView {
                Label("Aún no hay reportes", systemImage: "leaf")
            } description: {
                Text("Toca + para registrar el primer problema ambiental.")
            } actions: {
                VStack(spacing: 10) {
                    Button("Crear reporte") { mostrandoFormulario = true }
                        .buttonStyle(.borderedProminent)
                    Button("Cargar ejemplos del campus", systemImage: "photo.stack") {
                        withAnimation(.snappy) { _ = almacen.cargarEjemplos() }
                    }
                    .buttonStyle(.bordered)
                }
            }
        } else {
            ContentUnavailableView {
                Label("Sin resultados", systemImage: "line.3.horizontal.decrease.circle")
            } description: {
                Text("Ningún reporte coincide con los filtros elegidos.")
            }
        }
    }
}

private extension View {
    //quita separadores y fondo gris para que cada fila se vea como tarjeta
    func estiloFila() -> some View {
        listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
    }
}

private struct MenuFiltros: View {
    @Binding var filtro: FiltroReportes

    var body: some View {
        Menu {
            Picker("Categoría", selection: $filtro.categoria) {
                Text("Todas las categorías").tag(CategoriaReporte?.none)
                ForEach(CategoriaReporte.allCases) { categoria in
                    Label(categoria.rawValue, systemImage: categoria.simbolo)
                        .tag(Optional(categoria))
                }
            }
            .pickerStyle(.menu)

            Picker("Estado", selection: $filtro.estado) {
                Text("Todos los estados").tag(EstadoReporte?.none)
                ForEach(EstadoReporte.allCases) { estado in
                    Label(estado.rawValue, systemImage: estado.simbolo)
                        .tag(Optional(estado))
                }
            }
            .pickerStyle(.menu)

            if filtro.estaActivo {
                Button("Quitar filtros", systemImage: "xmark.circle", role: .destructive) {
                    filtro = FiltroReportes()
                }
            }
        } label: {
            Label(
                "Filtros",
                systemImage: filtro.estaActivo
                    ? "line.3.horizontal.decrease.circle.fill"
                    : "line.3.horizontal.decrease.circle"
            )
            .font(.title3)
        }
    }
}

#Preview {
    ListaReportesView()
        .environment(AlmacenReportes.vistaPrevia)
        .tint(Tema.verde)
}
