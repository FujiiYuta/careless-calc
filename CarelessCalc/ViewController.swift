//
//  ViewController.swift
//  Calculator
//
//  Created by Yuta Fujii on 22/01/2025.
//  Copyright © 2025 Yuta Fujii. All rights reserved.
//

import UIKit
import DeviceKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    //MARK: Outlets

    @IBOutlet weak var sequence: UILabel!
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var display: UILabel!

    //MARK: Variables

    private var brain = CalculatorBrain()
    private var userIsInTheMiddleOfTyping = false

    private var player: AVAudioPlayer?

    private var iPhoneModel: Device {
        return Device.realDevice(from: .current)
    }

    private var displayValue: Double {
        get {
            return Double(display.text ?? Constants.emptyString) ?? Double.nan
        }
        set {
            let tmp = String(newValue).removeAfterPointIfZero()
            display.text = tmp.setMaxLength(of: 8)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    //MARK: UIVIew Delegate

    override func viewDidLoad() {
        // round the corners of the calculator on iPhones with the notch.
        if Device.allDevicesWithSensorHousing.contains(iPhoneModel) {
            cornerView.layer.cornerRadius = Constants.cornerRadius
            cornerView.layer.masksToBounds = true
        }
    }

    //MARK: IBAction(s)

    @IBAction func touchDigit(_ sender: UIButton) {
        guard let digit = sender.currentTitle else { return }

        if userIsInTheMiddleOfTyping {
            guard let textCurrentlyInDisplay = display.text else { return }

            if digit == "." && (textCurrentlyInDisplay.range(of: Constants.decimalPoint) != nil) {
                return
            } else {
                let tmp = textCurrentlyInDisplay + digit
                display.text = tmp.setMaxLength(of: Constants.maxStringLength)
            }

        } else {
            if digit == Constants.decimalPoint {
                display.text = Constants.pointAfterZero
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }

        sequence.text = brain.description
    }

    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }

        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }

        if let result = brain.result {
            displayValue = result
            switch brain.alertType {
            case ._2143:
                playErrorSound(name: "2143")
            case .mistake:
                playErrorSound(name: "stupid1")
            case .correct:
                break
            }
        }

        sequence.text = brain.description
    }

    /// エラー音声を再生する
    private func playErrorSound(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "m4a") else {
            print("音源ファイルが見つかりません")
            return
        }

        do {
            // AVAudioPlayerのインスタンス化
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))

            // AVAudioPlayerのデリゲートをセット
            player?.delegate = self

            // 音声の再生
            player?.play()
        } catch {
        }
    }

}

extension ViewController {
    struct Constants {
        static let cornerRadius: CGFloat = 35.0
        static let decimalPoint: String = "."
        static let emptyString: String = ""
        static let maxStringLength: Int = 8
        static let pointAfterZero: String = "0."
    }
}
