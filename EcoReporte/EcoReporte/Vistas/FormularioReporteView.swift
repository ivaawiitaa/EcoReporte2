//
//  FormularioReporteView.swift
//  EcoReporte
//
//  Captura de un nuevo reporte con fotografia y validacion de campos.
//

import SwiftUI
import PhotosUI

struct FormularioReporteView: View {
    @Environment(AlmacenReportes.self) private var almacen
    @Environment(\.dismiss) private var dismiss

    @State private var borrador = BorradorReporte()
    @State private var seleccionFoto: PhotosPickerItem?
    @State private var vistaPrevia: UIImage?
    @State private var procesandoFoto = false
    @State private var avisoFoto: String?
    //los errores solo se muestran despues del primer intento de guardar
    @State private var intentoGuardar = false
    @State private var errorAlGuardar: String?

    private var errores: [ErrorValidacion] {
        intentoGuardar ? ValidadorReporte.validar(borrador) : []
    }

    var body: some View {
        NavigationStack {
            Form {
                if !errores.isEmpty {
                    Section {
                        MensajeError(texto: ValidadorReporte.resumen(de: errores))
                    }
                }

                Section {
                    selectorFoto
                        .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    if let avisoFoto {
                        Label(avisoFoto, systemImage: "hand.raised.fill")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                    mensajeError(para: .foto)
                } header: {
                    Text("Fotografía *")
                } footer: {
                    Label("Evita fotografiar rostros, placas de autos o documentos con datos personales.",
                          systemImage: "lock.shield")
                }

                Section {
                    selectorCategoria
                        .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    mensajeError(para: .categoria)
                } header: {
                    Text("Categoría *")
                }

                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        campo(simbolo: "textformat") {
                            TextField("Título (ej. Fuga en bebedero)", text: $borrador.titulo)
                        }
                        mensajeError(para: .titulo)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        campo(simbolo: "mappin.and.ellipse") {
                            TextField("Ubicación (ej. Edificio B, planta baja)", text: $borrador.ubicacion)
                        }
                        mensajeError(para: .ubicacion)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        campo(simbolo: "text.alignleft") {
                            TextField("¿Qué observaste y desde cuándo?", text: $borrador.descripcion, axis: .vertical)
                                .lineLimit(3...8)
                        }
                        mensajeError(para: .descripcion)
                    }
                } header: {
                    Text("Datos del reporte *")
                } footer: {
                    Text("* Campos obligatorios")
                }

                Section {
                    SelectorUbicacionMapa(coordenada: $borrador.coordenada)
                        .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                } header: {
                    Text("Lugar en el mapa (opcional)")
                }
            }
            .navigationTitle("Nuevo reporte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { guardar() }
                        .fontWeight(.semibold)
                        .disabled(procesandoFoto)
                }
            }
            .task(id: seleccionFoto) {
                await cargarFoto(seleccionFoto)
            }
            //evita perder lo capturado si se desliza la hoja hacia abajo por error
            .interactiveDismissDisabled(borrador != BorradorReporte())
            .alert("No se pudo guardar", isPresented: Binding(
                get: { errorAlGuardar != nil },
                set: { if !$0 { errorAlGuardar = nil } }
            )) {
                Button("Aceptar", role: .cancel) {}
            } message: {
                Text(errorAlGuardar ?? "")
            }
        }
    }

    //recuadro grande que abre la biblioteca de fotos y muestra la vista previa
    private var selectorFoto: some View {
        PhotosPicker(selection: $seleccionFoto, matching: .images) {
            Color.clear
                .frame(height: 220)
                .overlay {
                    if procesandoFoto {
                        ProgressView("Revisando fotografía…")
                    } else if let vistaPrevia {
                        Image(uiImage: vistaPrevia)
                            .resizable()
                            .scaledToFill()
                            .accessibilityLabel("Vista previa de la fotografía seleccionada")
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "camera.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                                .frame(width: 64, height: 64)
                                .background(Tema.degradado, in: Circle())
                            Text("Agregar fotografía")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Toca para elegir de tu biblioteca")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if vistaPrevia != nil && !procesandoFoto {
                        Label("Cambiar", systemImage: "arrow.triangle.2.circlepath")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(10)
                    }
                }
                .background(Tema.verde.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Tema.radio))
                .overlay {
                    RoundedRectangle(cornerRadius: Tema.radio)
                        .strokeBorder(
                            errores.contains(.fotoFaltante) ? Color.red : Tema.verde.opacity(0.5),
                            style: StrokeStyle(lineWidth: 2, dash: vistaPrevia == nil ? [8, 6] : [])
                        )
                }
        }
        .buttonStyle(.plain)
        .disabled(procesandoFoto)
    }

    //botones de colores en lugar de una lista desplegable
    private var selectorCategoria: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 8)], spacing: 8) {
            ForEach(CategoriaReporte.allCases) { categoria in
                let seleccionada = borrador.categoria == categoria
                Button {
                    withAnimation(.snappy) { borrador.categoria = categoria }
                } label: {
                    Label(categoria.rawValue, systemImage: categoria.simbolo)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundStyle(seleccionada ? .white : categoria.color)
                        .background(seleccionada ? categoria.color : categoria.color.opacity(0.12),
                                    in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(seleccionada ? .isSelected : [])
            }
        }
    }

    private func campo<Contenido: View>(simbolo: String, @ViewBuilder contenido: () -> Contenido) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: simbolo)
                .foregroundStyle(Tema.verde)
                .frame(width: 22)
            contenido()
        }
    }

    @ViewBuilder
    private func mensajeError(para campo: CampoReporte) -> some View {
        if let error = errores.first(where: { $0.campo == campo }) {
            MensajeError(texto: error.mensaje)
        }
    }

    @MainActor
    private func cargarFoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        procesandoFoto = true
        avisoFoto = nil
        defer { procesandoFoto = false }

        guard let datos = try? await item.loadTransferable(type: Data.self),
              let foto = await ProcesadorFoto.procesar(datos) else {
            avisoFoto = "No se pudo abrir la imagen. Intenta con otra."
            return
        }
        if foto.tieneRostros {
            //si ya habia una foto valida se conserva
            avisoFoto = "La imagen parece mostrar el rostro de una persona. Para proteger su privacidad elige otra."
            return
        }
        vistaPrevia = foto.imagen
        borrador.foto = foto.datos
    }

    private func guardar() {
        intentoGuardar = true
        guard errores.isEmpty else { return }
        do {
            try almacen.agregar(borrador)
            dismiss()
        } catch {
            errorAlGuardar = error.localizedDescription
        }
    }
}

#Preview {
    FormularioReporteView()
        .environment(AlmacenReportes.vistaPrevia)
        .tint(Tema.verde)
}
