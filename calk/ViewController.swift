//
//  ViewController.swift
//  calk
//
//  Created by Kam Lotfull on 01.01.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var history: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brain.addUnaryOperation(symbol: "√") {
            self.display.textColor = UIColor.green
            return sqrt($0)
        }
    }
    
    @IBAction func backspaceButton(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if var text = display.text {
                text.remove(at: text.index(before: text.endIndex))
                if text.isEmpty {
                    text = "0"
                    userIsInTheMiddleOfTyping = false
                }
                display.text = text
            }
        }
    }
    
    @IBAction func ClearButton(_ sender: UIButton) {
        brain = CalcBrain()
        display.text = "0"
        history.text = " "
        userIsInTheMiddleOfTyping = false
        displayValue = nil
    }
    private var userIsInTheMiddleOfTyping = false {
        didSet {
            if !userIsInTheMiddleOfTyping {
                userIsInTheMiddleOfTypingFloat = false
            }
        }
    }
    private var userIsInTheMiddleOfTypingFloat = false

    
    // var characters: String.CharacterView {get}
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        var digit = sender.currentTitle!
        
        if digit == "." {
            if userIsInTheMiddleOfTypingFloat { return }
            if !userIsInTheMiddleOfTyping { digit = "0." }
            userIsInTheMiddleOfTypingFloat = true
        }
        //sender.setTitle("\(digit)!", for: UIControlState.normal)
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue: Double? {
        get { // если мы где-то присваиваем а = displayValue
            if let text = display.text {
                if let value = Double(text) {
                    return value
                }
                return nil
            }
            return nil
        }
        set { // если мы где-то изменяем displayValue = a
            if let value = newValue {
                let rounded_value = value.rounded(FloatingPointRoundingRule.towardZero)
                let value1 = rounded_value + Double(round(10000000000*(value - rounded_value))/10000000000)
                display.text = String(value1)
                if brain.isPartialResult {
                    history.text = brain.description + "..."
                } else {
                    history.text = brain.description + "="
                }
            } else {
                display.text = "0"
                history.text = " "
                userIsInTheMiddleOfTyping = false
            }
        }
    }

    private var brain = CalcBrain()
    
    var savedProgram: CalcBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        
    }

}

