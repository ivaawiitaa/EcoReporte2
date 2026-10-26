//
//  ProcesadorFoto.swift
//  EcoReporte
//
//  Prepara la imagen elegida: la reduce, la convierte a JPEG
//  y revisa si aparece algun rostro para proteger la privacidad.
//

import UIKit
import Vision

struct FotoProcesada {
    let imagen: UIImage
    let datos: Data
    let tieneRostros: Bool
}

enum ProcesadorFoto {
    //lado mas largo permitido; evita guardar fotos de varios MB
    static let ladoMaximo: CGFloat = 1600

    //el trabajo pesado se hace fuera del hilo principal para no congelar la interfaz
    static func procesar(_ datos: Data) async -> FotoProcesada? {
        await Task.detached(priority: .userInitiated) { () -> FotoProcesada? in
            guard let original = UIImage(data: datos) else { return nil }
            let imagen = ProcesadorFoto.reducir(original)
            guard let jpeg = imagen.jpegData(compressionQuality: 0.8) else { return nil }
            return FotoProcesada(
                imagen: imagen,
                datos: jpeg,
                tieneRostros: ProcesadorFoto.contieneRostros(imagen)
            )
        }.value
    }

    //al redibujar la imagen tambien se corrige su orientacion
    static func reducir(_ imagen: UIImage) -> UIImage {
        let ladoMayor = max(imagen.size.width, imagen.size.height)
        let escala = min(1, ladoMaximo / ladoMayor)
        let tamano = CGSize(width: imagen.size.width * escala, height: imagen.size.height * escala)

        let formato = UIGraphicsImageRendererFormat.default()
        formato.scale = 1
        return UIGraphicsImageRenderer(size: tamano, format: formato).image { _ in
            imagen.draw(in: CGRect(origin: .zero, size: tamano))
        }
    }

    //si Vision falla se regresa false para no bloquear al usuario
    static func contieneRostros(_ imagen: UIImage) -> Bool {
        guard let cgImage = imagen.cgImage else { return false }
        let solicitud = VNDetectFaceRectanglesRequest()
        let manejador = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try manejador.perform([solicitud])
            return !(solicitud.results ?? []).isEmpty
        } catch {
            return false
        }
    }
}
