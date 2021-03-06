//
//  PasswordField.swift
//  PasswordTextField
//
//  Created by Ben Gohlke on 6/26/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

enum PasswordStrength {
    case weak
    case medium
    case strong
}

class PasswordField: UIControl {
    
    // Public API - these properties are used to fetch the final password and strength values
    private (set) var password: String = ""
    
    private let standardMargin: CGFloat = 8.0
    private let textFieldContainerHeight: CGFloat = 50.0
    private let textFieldMargin: CGFloat = 6.0
    private let colorViewSize: CGSize = CGSize(width: 60.0, height: 5.0)
    
    private let labelTextColor = UIColor(hue: 233.0/360.0, saturation: 16/100.0, brightness: 41/100.0, alpha: 1)
    private let labelFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
    
    private let textFieldBorderColor = UIColor(hue: 208/360.0, saturation: 80/100.0, brightness: 94/100.0, alpha: 1)
    private let bgColor = UIColor(hue: 0, saturation: 0, brightness: 97/100.0, alpha: 1)
    
    // States of the password strength indicators
    private let unusedColor = UIColor(hue: 210/360.0, saturation: 5/100.0, brightness: 86/100.0, alpha: 1)
    private let weakColor = UIColor(hue: 0/360, saturation: 60/100.0, brightness: 90/100.0, alpha: 1)
    private let mediumColor = UIColor(hue: 39/360.0, saturation: 60/100.0, brightness: 90/100.0, alpha: 1)
    private let strongColor = UIColor(hue: 132/360.0, saturation: 60/100.0, brightness: 75/100.0, alpha: 1)
    
    var currentStrength: PasswordStrength? {
        didSet {
            switch currentStrength {
            case .weak:
                weakPasswordWasSet()
            case .medium:
                mediumPasswordWasSet()
            case .strong:
                strongPasswordWasSet()
            case .none:
                print("not sure what to do here")
            }
        }
    }
    
    private var titleLabel: UILabel = UILabel()
    private var textField: UITextField = UITextField()
    private var showHideButton: UIButton = UIButton()
    private var weakView: UIView = UIView()
    private var mediumView: UIView = UIView()
    private var strongView: UIView = UIView()
    private var strengthDescriptionLabel: UILabel = UILabel()
    
    func setup() {
        
        textField.delegate = self
        self.backgroundColor = bgColor
        
        titleLabel.text = "ENTER PASSWORD"
        titleLabel.textColor = labelTextColor
        titleLabel.font = labelFont
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
        
        textField.textContentType = .password
        textField.isSecureTextEntry = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderColor = textFieldBorderColor.cgColor
        textField.layer.borderWidth = 2
        textField.beginFloatingCursor(at: CGPoint(x: textFieldMargin, y: textFieldMargin))
        addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: textFieldMargin),
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: textFieldMargin),
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: textFieldMargin),
            textField.heightAnchor.constraint(equalToConstant: textFieldContainerHeight),
        ])
        
        showHideButton.translatesAutoresizingMaskIntoConstraints = false
        showHideButton.setImage(UIImage(named: "eyes-open"), for: .normal)
        showHideButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubview(showHideButton)
        NSLayoutConstraint.activate([
            showHideButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -50.0),
            showHideButton.topAnchor.constraint(equalTo: textField.topAnchor, constant: 10.0)
        ])
        
        weakView.backgroundColor = weakColor
        weakView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(weakView)
        NSLayoutConstraint.activate([
            weakView.widthAnchor.constraint(equalToConstant: colorViewSize.width),
            weakView.heightAnchor.constraint(equalToConstant: colorViewSize.height),
            weakView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: standardMargin),
            weakView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: standardMargin),
            weakView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -standardMargin)
        ])
        
        mediumView.frame.size = colorViewSize
        mediumView.backgroundColor = unusedColor
        mediumView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mediumView)
        NSLayoutConstraint.activate([
            mediumView.heightAnchor.constraint(equalToConstant: colorViewSize.height),
            mediumView.widthAnchor.constraint(equalToConstant: colorViewSize.width),
            mediumView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: standardMargin),
            mediumView.leadingAnchor.constraint(equalTo: weakView.trailingAnchor, constant: standardMargin),
            mediumView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -standardMargin)
        ])
        
        strongView.frame.size = colorViewSize
        strongView.backgroundColor = unusedColor
        strongView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(strongView)
        NSLayoutConstraint.activate([
            strongView.heightAnchor.constraint(equalToConstant: colorViewSize.height),
            strongView.widthAnchor.constraint(equalToConstant: colorViewSize.width),
            strongView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: standardMargin),
            strongView.leadingAnchor.constraint(equalTo: mediumView.trailingAnchor, constant: standardMargin),
            strongView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -standardMargin)
        ])
        
        strengthDescriptionLabel.text = "Too weak"
        strengthDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        strengthDescriptionLabel.textColor = labelTextColor
        strengthDescriptionLabel.font = labelFont
        addSubview(strengthDescriptionLabel)
        NSLayoutConstraint.activate([
            strengthDescriptionLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: textFieldMargin),
            strengthDescriptionLabel.leadingAnchor.constraint(equalTo: strongView.trailingAnchor, constant: standardMargin),
            strengthDescriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3.0)
        ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    @objc func buttonTapped() {
        if showHideButton.imageView?.image == UIImage(named: "eyes-open") {
            textField.isSecureTextEntry = true
            showHideButton.setImage(UIImage(named: "eyes-closed"), for: .normal)
        } else {
            textField.isSecureTextEntry = false
            showHideButton.setImage(UIImage(named: "eyes-open"), for: .normal)
        }
    }
    
    func weakPasswordWasSet() {
        
        
        
        strengthDescriptionLabel.text = "Too weak"
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.weakView.transform = CGAffineTransform(scaleX: 1, y: 1.75)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 1) {
                self.weakView.transform = .identity
            }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.strongView.backgroundColor = self.unusedColor
                self.mediumView.backgroundColor = self.unusedColor
            }
        }, completion: nil)
        
    }
    
    func mediumPasswordWasSet() {
        
        strengthDescriptionLabel.text = "Could be stronger"
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.mediumView.transform = CGAffineTransform(scaleX: 1, y: 1.75)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 1) {
                self.mediumView.transform = .identity
            }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.strongView.backgroundColor = self.unusedColor
                self.mediumView.backgroundColor = self.mediumColor
            }
        }, completion: nil)
        
    }
    
    func strongPasswordWasSet() {
        
        strengthDescriptionLabel.text = "Strong Password!"
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.strongView.transform = CGAffineTransform(scaleX: 1, y: 1.75)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 1) {
                self.strongView.transform = .identity
            }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                self.strongView.backgroundColor = self.strongColor
                self.mediumView.backgroundColor = self.mediumColor
            }
        }, completion: nil)
        
    }
    
} //End of class

//MARK: - Extensions -

extension PasswordField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let numberOfCharacters = textField.text?.count else { return false }
        
        if numberOfCharacters <= 9 {
            if currentStrength != PasswordStrength.weak {
                currentStrength = .weak
            }
        } else if numberOfCharacters <= 19 {
            if currentStrength != PasswordStrength.medium {
                currentStrength = .medium
            }
        } else if numberOfCharacters >= 20 {
            if currentStrength != PasswordStrength.strong {
                currentStrength = .strong
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let text = self.textField.text else { return false }
        let numberOfCharacters = text.count
        
        if numberOfCharacters <= 9 {
            currentStrength = .weak
        } else if numberOfCharacters <= 19 {
            currentStrength = .medium
        } else if numberOfCharacters >= 20 {
            currentStrength = .strong
        }
        
        
        self.textField.resignFirstResponder()
        return true
        
    }
    
} //End of extension
