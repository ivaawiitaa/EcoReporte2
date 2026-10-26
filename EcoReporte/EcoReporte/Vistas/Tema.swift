//
//  Tema.swift
//  EcoReporte
//
//  Colores y estilos compartidos para que todas las pantallas se vean igual.
//

import SwiftUI

enum Tema {
    static let verde = Color(red: 0.18, green: 0.55, blue: 0.34)
    static let verdeOscuro = Color(red: 0.07, green: 0.35, blue: 0.24)
    static let degradado = LinearGradient(
        colors: [verde, verdeOscuro],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let fondo = Color(.systemGroupedBackground)
    static let fondoTarjeta = Color(.secondarySystemGroupedBackground)
    static let radio: CGFloat = 16
}

extension CategoriaReporte {
    var color: Color {
        switch self {
        case .basura: return .brown
        case .agua: return .cyan
        case .areasVerdes: return .green
        case .aire: return .gray
        case .ruido: return .purple
        case .energia: return Color(red: 0.85, green: 0.6, blue: 0.0)
        case .otro: return .teal
        }
    }
}

extension EstadoReporte {
    var color: Color {
        switch self {
        case .pendiente: return .orange
        case .enProceso: return .blue
        case .resuelto: return .green
        }
    }
}

extension View {
    //fondo blanco redondeado con sombra suave
    func estiloTarjeta(radio: CGFloat = Tema.radio) -> some View {
        background(Tema.fondoTarjeta, in: RoundedRectangle(cornerRadius: radio))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }
}
