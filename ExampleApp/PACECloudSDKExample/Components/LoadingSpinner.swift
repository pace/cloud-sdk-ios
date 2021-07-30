//
//  LoadingSpinner.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import SwiftUI

// https://github.com/KeatoonMask/SwiftUI-Animation
struct LoadingSpinner: View {
    private let rotationTime: Double = 0.75
    private let animationTime: Double = 1.9 // Sum of all animation times
    private let fullRotation: Angle = .degrees(360)
    private static let initialDegree: Angle = .degrees(270)

    @State private var spinnerStart: CGFloat = 0.0
    @State private var spinnerEndS1: CGFloat = 0.03
    @State private var spinnerEndS2S3: CGFloat = 0.03

    @State private var rotationDegreeS1 = initialDegree
    @State private var rotationDegreeS2 = initialDegree
    @State private var rotationDegreeS3 = initialDegree

    private let color: Color
    private let loadingText: String?

    init(color: Color = .brand, loadingText: String? = nil) {
        self.color = color
        self.loadingText = loadingText
    }

    var body: some View {
        VStack {
            ZStack {
                // S3
                SpinnerCircle(start: spinnerStart, end: spinnerEndS2S3, rotation: rotationDegreeS3, color: color)

                // S2
                SpinnerCircle(start: spinnerStart, end: spinnerEndS2S3, rotation: rotationDegreeS2, color: color)

                // S1
                SpinnerCircle(start: spinnerStart, end: spinnerEndS1, rotation: rotationDegreeS1, color: color)

            }
            .frame(width: 150, height: 150)
            if let loadingText = loadingText {
                Spacer()
                    .frame(height: .defaultPadding / 2)
                Text(loadingText)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
        .onAppear {
            animateSpinner()
            Timer.scheduledTimer(withTimeInterval: animationTime, repeats: true) { _ in
                animateSpinner()
            }
        }
    }

    // MARK: Animation methods
    func animateSpinner(with duration: Double, completion: @escaping (() -> Void)) {
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            withAnimation(Animation.easeInOut(duration: self.rotationTime)) {
                completion()
            }
        }
    }

    func animateSpinner() {
        animateSpinner(with: rotationTime) { self.spinnerEndS1 = 1.0 }

        animateSpinner(with: (rotationTime * 2) - 0.025) {
            rotationDegreeS1 += fullRotation
            spinnerEndS2S3 = 0.8
        }

        animateSpinner(with: (rotationTime * 2)) {
            spinnerEndS1 = 0.03
            spinnerEndS2S3 = 0.03
        }

        animateSpinner(with: (rotationTime * 2) + 0.0525) { rotationDegreeS2 += fullRotation }

        animateSpinner(with: (rotationTime * 2) + 0.225) { rotationDegreeS3 += fullRotation }
    }
}

// MARK: SpinnerCircle
struct SpinnerCircle: View {
    var start: CGFloat
    var end: CGFloat
    var rotation: Angle
    var color: Color

    var body: some View {
        Circle()
            .trim(from: start, to: end)
            .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .fill(color)
            .rotationEffect(rotation)
    }
}
