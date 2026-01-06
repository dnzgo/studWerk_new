//
//  UserTypeSelectionView.swift
//  test
//
//  Created by Emir Yalçınkaya on 6.01.2026.
//

import SwiftUI

struct UserTypeSelectionView: View {
    @Binding var path: [Route]
    @State private var selected: UserType = .student

    var body: some View {
        VStack(spacing: 28) {

            VStack(spacing: 10) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)

                Text("StudWerk")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Choose your account type to continue")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 24)

            Text("I am a...")
                .font(.headline)

            VStack(spacing: 16) {
                SimpleUserTypeButton(
                    title: "Student",
                    subtitle: "Looking for part-time work",
                    icon: "person.fill",
                    tint: .blue,
                    isSelected: selected == .student
                ) { selected = .student }

                SimpleUserTypeButton(
                    title: "Employer",
                    subtitle: "Hiring students for easy jobs",
                    icon: "building.2.fill",
                    tint: .green,
                    isSelected: selected == .employer
                ) { selected = .employer }
            }
            .frame(maxWidth: 620)

            Button {
                path.append(.register(selected))
            } label: {
                Text("Continue")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: 520)
                    .frame(height: 52)
                    .background(Color.blue)
                    .cornerRadius(14)
            }
            .padding(.top, 6)

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .top) {
        Color.clear.frame(height: 60)
        }
    }
}

struct SimpleUserTypeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : tint)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.85) : .secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? tint : Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("UserTypeSelectionView") {
    NavigationStack {
        UserTypeSelectionView(path: .constant([]))
    }
}
