//
//  EventsExampleController.swift
//  Example
//
//  Created by Victor Sukochev on 02/03/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import UIKit
import Macaw

enum Tool {
    case freeDraw
    case text
    case line
    case ellipse
    case rect
    case rectLine
    case arrow
    case asterisk
    case none
}

class ViewController: UIViewController {
    
    var shapeActive: Bool = false
    
    var shapeTransformations: [Int:(dx:Double,dy:Double,scale:Double, angle:Double)] = [:]
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var selectionButton: UIButton!
    
    var macawView = MacawView()
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message"
        return textField
    }()
    
    let stroke = Stroke(fill: Color.red, width: 2.0)
    
    var group: Group!
    var canvas: Shape!
    var shapesGroup: Group = Group()
    var redoShapes: [Node] = []
    
    var newShape: CustomShape!
    
    var customTexts: [CustomText] = []
    
    //var newCustomText: CustomText!
    
    var canvasActive: Bool = false
    var activeTool: Tool = .none
    let image = #imageLiteral(resourceName: "Medical_X-Ray_imaging_AAR02_nevit")
    var backgroundView = UIView()
    
    var bottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configMacawView()
        createCanvas()
        
        view.addSubview(messageInputContainerView)
        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        messageInputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        messageInputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupInputComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        messageInputContainerView.isHidden = true
        
        inputTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        inputTextField.addTarget(self, action: #selector(textFieldBecameFirstResponder(_:)), for: .editingDidBegin)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let customText = customTexts.last
        customText?.textNode.text = textField.text ?? ""
    }
    
    @objc func textFieldBecameFirstResponder(_ textField: UITextField) {
        let customText = customTexts.last
        textField.text = customText?.textNode.text
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        buttonsStackView.isHidden = false
    }
    
    func setupInputComponents() {
        messageInputContainerView.addSubview(inputTextField)
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.leadingAnchor.constraint(equalTo: messageInputContainerView.leadingAnchor, constant: 8).isActive = true
        inputTextField.trailingAnchor.constraint(equalTo: messageInputContainerView.trailingAnchor).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor).isActive = true
        inputTextField.topAnchor.constraint(equalTo: messageInputContainerView.topAnchor).isActive = true
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.messageInputContainerView.isHidden = !self.messageInputContainerView.isHidden
                self.view.layoutIfNeeded()
            }) { (completed) in
            }
        }
    }
    
    func createCanvas() {
        self.canvas = Shape(form: Rect(x: 0, y: 0, w: Double(image.size.width), h: Double(image.size.height)), fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        
        var startPoint = Point()
        
        // creating new shape during first touch on canvas
        canvas.onTouchPressed { event in
            
            guard let loc = event.points.first?.location(in: .scene)  else {
                return
            }
            
            startPoint = loc
            
            self.redoShapes = []
            
            switch self.activeTool {
            case .freeDraw:
                self.newShape = FreeDrawing(startPoint: startPoint, lastPoint: startPoint)
            case .text:
                return
                //self.newCustomText = CustomText(text: "asd asdas dsa dsadas", startPoint: startPoint)
//                self.newShape = CustomText(text: "asd asdas dsa dsadas", startPoint: startPoint)
//                let customText = self.newShape as! CustomText
//                customText.delegate = self
            case .line:
                self.newShape = CustomLine(startPoint: startPoint, lastPoint: startPoint)
            case .ellipse:
                self.newShape = CustomEllipse(startPoint: startPoint, lastPoint: startPoint)
            case .rect:
                self.newShape = CustomRect(startPoint: startPoint, lastPoint: startPoint)
            case .arrow:
                self.newShape = Arrow(startPoint: startPoint, lastPoint: startPoint)
            case .rectLine:
                self.newShape = RectLine(startPoint: startPoint, lastPoint: startPoint)
            case .asterisk:
                self.newShape = Asterisk(startPoint: startPoint, lastPoint: startPoint)
            case .none:
                return
            }
            
            
//            if self.activeTool == .text {
//
//            } else {
                self.group.contents.append(self.newShape)
            //}
        }
        
        // resizing new shape when moving first touch
        canvas.onTouchMoved { (event) in
                    
            //self.canvasActive = true
            
            if self.activeTool == .none || self.activeTool == .text {
                return
            }
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            self.newShape.updateForm(startPoint: startPoint, lastPoint: loc)
            
            if self.activeTool == .freeDraw {
                startPoint = loc
            }
        }
        
        // leaving new shape on canvas when releasing first touch
        canvas.onTouchReleased { (event) in
            
            guard self.activeTool != .none else { return }
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
//            if let customText = self.newShape as? CustomText {
//                //let center = self.newShape.getCenter()
//                self.shapeTransformations[self.newShape.hash] = (0,0, 1, 0)
//
//                customText.rect.onTap(f: { (event) in
//                    print("customText.rect.onTap")
//                    customText.active = !customText.active
//                    if customText.active {
//                        let stroke = Stroke(fill: Color.blue, width: 2.0)
//                        customText.updateStroke(stroke: stroke)
//                        self.inputTextField.becomeFirstResponder()
//                    } else {
//                        let stroke = Stroke(fill: Color.red, width: 2.0)
//                        customText.updateStroke(stroke: stroke)
//                        self.inputTextField.resignFirstResponder()
//                    }
//                })
//
//            } else
            
            if self.activeTool == .text {
                let customText = CustomText(text: "asd asdas dsa dsadas", startPoint: startPoint)
                self.customTexts.append(customText)
                
                self.shapeTransformations[customText.hash] = (0,0, 1, 0)
                
                customText.onTap(f: { (event) in
                    print("customText.onTap")
                    customText.active = !customText.active
                    if customText.active {
                        
                        self.customTexts.removeAll(where: { (text) -> Bool in
                            text == customText
                        })
                        
                        for text in self.customTexts {
                            let stroke = Stroke(fill: Color.red, width: 2.0)
                            text.updateStroke(stroke: stroke)
                        }
                        
                        self.customTexts.append(customText)
                        
                        let stroke = Stroke(fill: Color.blue, width: 2.0)
                        customText.updateStroke(stroke: stroke)
                        self.inputTextField.becomeFirstResponder()
                    } else {
                        let stroke = Stroke(fill: Color.red, width: 2.0)
                        customText.updateStroke(stroke: stroke)
                        self.inputTextField.resignFirstResponder()
                    }
                })
                
                customText.onPan { event in
                    
                    print("customText.onPan")
                    
                    //self.scrollview.isScrollEnabled = false
                    
                    let transform = self.shapeTransformations[customText.hash]
                    self.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: customText.hash)
                    self.updatePlace(node: customText)
                    //}
                }
                
                self.group.contents.append(customText)
                
                return
                
            } else
            
            if let _ = self.newShape as? FreeDrawing {
                //let center = self.newShape.getCenter()
                self.shapeTransformations[self.newShape.hash] = (startPoint.x,startPoint.y, 1, 0)
            } else {
                self.group.contents.removeLast()
                self.newShape.updateForm(startPoint: Point(0, 0), lastPoint: Point(loc.x - startPoint.x, loc.y - startPoint.y))
                self.newShape.activateCircleAction()
                self.newShape.place = Transform.move(dx: startPoint.x, dy: startPoint.y).scale(sx: 1, sy: 1)
                //let center = self.newShape.getCenter()
                self.shapeTransformations[self.newShape.hash] = (startPoint.x,startPoint.y, 1, 0)
            }

//            self.newShape.onTap(f: { (event) in
//
//                print("newShape.onTap")
//
//                guard let node = event.node else { print("problem on panel pan")
//                    return
//                }
//
//                if let customShape = node as? CustomShape {
//                    customShape.isActive = !customShape.isActive
//                }
//
//            })
            
            // moving existing shape
            self.newShape.onPan { event in
                
                print("newShape.onPan")
                
                //if !self.canvasActive {
                    guard let node = event.node else { print("problem on panel pan")
                        return
                    }
                    
                    //self.scrollview.isScrollEnabled = false
                    
                    let transform = self.shapeTransformations[node.hash]
                    self.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: node.hash)
                    self.updatePlace(node: node)
                //}
            }
            
            // resizing existing shape
            self.newShape.onPinch { event in
                
                print("newShape.onPinch")
                
                guard let node = event.node else { print("problem on panel pinch")
                    return
                }
                
                if let _ = node as? CustomText {
                    return
                }
                
                let transform = self.shapeTransformations[node.hash]
                self.shapeTransformations.updateValue((transform!.dx, transform!.dy, transform!.scale * event.scale, transform!.angle), forKey: node.hash)
                self.updatePlace(node: node)
                
                let newStroke = Stroke(fill: Color.red, width: self.stroke.width/(transform!.scale * event.scale))
                if let shape = node as? CustomShape {
                    shape.updateStroke(stroke: newStroke)
                }
            }
            
            self.newShape.onRotate { event in
                
                print("newShape.onRotate")
                
                guard let node = event.node else { print("problem on panel rotate")
                    return
                }
                
                if let _ = node as? CustomText {
                    return
                }
                
                let transform = self.shapeTransformations[node.hash]
                self.shapeTransformations.updateValue((transform!.dx, transform!.dy, transform!.scale, transform!.angle + event.angle), forKey: node.hash)
                self.updatePlace(node: node)
            }
            
            self.shapesGroup.contents.append(self.newShape)
            self.canvasActive = false
        }
        
        group = Group(contents: [canvas, shapesGroup])
        macawView.node = group
        scrollview.bounces = false
    }
    
    func updatePlace(node: Node) {
        
        let shape = node as! CustomShape
        
        if let _ = shape as? FreeDrawing {
            return
        }
        
        let center = shape.getCenter()
        let transform = self.shapeTransformations[node.hash]
        
        node.place = Transform.move(dx: transform!.dx + center!.x, dy: transform!.dy + center!.y).scale(sx: transform!.scale, sy: transform!.scale).rotate(angle: transform!.angle).move(dx: -center!.x, dy: -center!.y)
    }
    
    func configMacawView(){
        
        scrollview.isScrollEnabled = false
        scrollview.bounces = false
        //scrollview.delegate = self
        
        scrollview.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.centerXAnchor.constraint(equalTo: scrollview.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: scrollview.centerYAnchor).isActive = true
        backgroundView.widthAnchor.constraint(equalTo:scrollview.widthAnchor).isActive = true
        backgroundView.heightAnchor.constraint(equalTo:scrollview.heightAnchor).isActive = true
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollview.contentSize = image.size

        backgroundView.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo:backgroundView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo:backgroundView.heightAnchor).isActive = true
        
        macawView.backgroundColor = .clear
        macawView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(macawView)
        
        macawView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        macawView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        macawView.widthAnchor.constraint(equalTo:imageView.widthAnchor).isActive = true
        macawView.heightAnchor.constraint(equalTo:imageView.heightAnchor).isActive = true
    }
    
    @IBAction func freeDrawingTool(_ sender: UIButton) {
        activeTool = .freeDraw
    }
    
    @IBAction func textTool(_ sender: UIButton) {
        activeTool = .text
    }
    
    @IBAction func activeLineTool(_ sender: UIButton) {
        activeTool = .line
    }
    @IBAction func activeRectTool(_ sender: UIButton) {
        activeTool = .rect
    }
    @IBAction func activeCircleTool(_ sender: Any) {
        activeTool = .ellipse
    }
    @IBAction func activeShapeTool(_ sender: Any) {
        activeTool = .rectLine
    }
    @IBAction func activeArrowTool(_ sender: Any) {
        activeTool = .arrow
    }
    @IBAction func activeAsteriskTool(_ sender: Any) {
        activeTool = .asterisk
    }
    @IBAction func activateSelectionTool(_ sender: Any) {
        selectionButton.isSelected = !selectionButton.isSelected
        let first = group.contents.remove(at: 0)
        group.contents.append(first)
    }
    @IBAction func undoTool(_ sender: Any) {
        if let undoneNode = shapesGroup.contents.popLast() {
            if let freeDrawing = undoneNode as? FreeDrawing {
                freeDrawing.deleteShape()
            }
            redoShapes.append(undoneNode)
        }
    }
    
    @IBAction func redoTool(_ sender: Any) {
        if let redoneNode = redoShapes.popLast() {
            if let freeDrawing = redoneNode as? FreeDrawing {
                freeDrawing.redoShape()
            }
            shapesGroup.contents.append(redoneNode)
        }
    }
    
}

//extension ViewController: UIScrollViewDelegate {
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return backgroundView
//    }
//}

extension ViewController: CustomTextDelegate {
    
    func activateKeyboard(customText: CustomText, activate: Bool) {
        if activate {
            self.inputTextField.becomeFirstResponder()
            self.messageInputContainerView.isHidden = true
        } else {
            self.inputTextField.becomeFirstResponder()
            self.messageInputContainerView.isHidden = false
        }
    }
}
