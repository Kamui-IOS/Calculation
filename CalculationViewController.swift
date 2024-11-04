//
//  CalculationViewController.swift
//  Calculation
//
//  Created by Hoang Nam on 4/11/24.
//

import UIKit
import PencilKit
import Vision

class CalculationViewController: UIViewController, PKCanvasViewDelegate {
    private let questionLabel = UILabel()
    private let canvasView = PKCanvasView()
    private let feedbackLabel = UILabel()
    private var answer = "20" // Đáp án mẫu

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    private func setupUI() {
        // Cấu hình nhãn câu hỏi
        questionLabel.text = "15 + 5 = ?"
        questionLabel.font = UIFont.systemFont(ofSize: 28)
        questionLabel.textAlignment = .center
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionLabel)
        
        // Cấu hình canvas vẽ tay
        canvasView.delegate = self
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvasView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        canvasView.layer.cornerRadius = 12
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        
        // Cấu hình nhãn phản hồi
        feedbackLabel.font = UIFont.systemFont(ofSize: 24)
        feedbackLabel.textAlignment = .center
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(feedbackLabel)
        
        // Cài đặt layout với AutoLayout
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            canvasView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            canvasView.heightAnchor.constraint(equalToConstant: 300),
            
            feedbackLabel.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: 20),
            feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // Nhận diện chữ viết tay khi canvas thay đổi
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        recognizeText(from: canvasView.drawing.image(from: canvasView.bounds, scale: 1.0))
    }

    private func recognizeText(from image: UIImage) {
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let self = self else { return }
            if let observations = request.results as? [VNRecognizedTextObservation] {
                let recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined()
                
                // Kiểm tra đáp án
                self.checkAnswer(recognizedText)
            }
        }
        request.recognitionLevel = .accurate
        
        guard let cgImage = image.cgImage else { return }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }

    private func checkAnswer(_ userAnswer: String) {
        if userAnswer == answer {
            feedbackLabel.text = "Correct!"
            feedbackLabel.textColor = .green
        } else {
            feedbackLabel.text = "Try Again!"
            feedbackLabel.textColor = .red
        }
    }
}

