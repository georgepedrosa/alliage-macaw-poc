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
    case protractor
    case arrow
    case asterisk
    case none
}

class ViewController: UIViewController {
    
    var shapeActive: Bool = false
    
    var shapeTransformations: [Int:(dx:Double,dy:Double,scale:Double, angle:Double)] = [:]
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var freeButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var lineButton: UIButton!
    @IBOutlet weak var rectButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var protractorButton: UIButton!
    @IBOutlet weak var arcButton: UIButton!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var asteriskButton: UIButton!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var handButton: UIButton!
    
    var macawView = MacawView()
    
    var lastSelectedButton: UIButton!
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextView: UITextView = {
        let textView = UITextView()
        return textView
    }()
    
    let stroke = Stroke(fill: Color.red, width: 5.0)
    let textColor = Color.red
    
    var group: Group!
    var canvas: Shape!
    var shapesGroup: Group = Group()
    var redoShapes: [Node] = []
    
    var tempShapes: [Node] = []
    
    var newShape: CustomShape!
    
    var customTexts: [CustomText] = []
    var isKeyboardShowing: Bool = false
    
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
        configInputNotifications()
        
    }
    
    func setupInputComponents() {
        messageInputContainerView.addSubview(inputTextView)
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.leadingAnchor.constraint(equalTo: messageInputContainerView.leadingAnchor, constant: 8).isActive = true
        inputTextView.trailingAnchor.constraint(equalTo: messageInputContainerView.trailingAnchor).isActive = true
        inputTextView.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor).isActive = true
        inputTextView.topAnchor.constraint(equalTo: messageInputContainerView.topAnchor).isActive = true
        messageInputContainerView.isHidden = true
        inputTextView.delegate = self
    }
    
    func configInputNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification //storing keyboard state for future reference on text events
            
            if !isKeyboardShowing { //deactivates all text nodes if keyboard is dismissed
                for text in self.customTexts {
                text.isActive = false
                }
            }
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0 //sets inputView constraint according to keyboard height
            self.messageInputContainerView.isHidden = !self.messageInputContainerView.isHidden

            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
            }
        }
    }
    
    func createCanvas() {
        self.canvas = Shape(form: Rect(x: 0, y: 0, w: Double(image.size.width), h: Double(image.size.height)), fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0)) //creating background canvas
        
        var startPoint = Point()
        
        // creating new shape during first touch on canvas
        canvas.onTouchPressed { event in
            
            if self.selectionButton.isSelected { return }
            
            guard let loc = event.points.first?.location(in: .scene)  else { return }
            
            startPoint = loc //stores initial touch point of new shape to be referenced on subsequent events
            
            self.redoShapes = [] //creating new shape empties redo shapes array
            
            //stores new shape to be referenced on subsequent events
            switch self.activeTool {
            case .freeDraw:
                self.newShape = FreeDrawing(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .text:
                return //text shape only added to canvas after touch released event
            case .line:
                self.newShape = CustomLine(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .ellipse:
                self.newShape = CustomEllipse(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .rect:
                self.newShape = CustomRect(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .arrow:
                self.newShape = Arrow(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .protractor:
                self.newShape = Protractor(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .asterisk:
                self.newShape = Asterisk(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .none:
                return
            }
            
            self.shapesGroup.contents.append(self.newShape)

        }
        
        // resizing new shape when moving first touch
        canvas.onTouchMoved { (event) in
            //self.canvasActive = true
            if self.activeTool == .none || self.activeTool == .text || self.selectionButton.isSelected { return }
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.newShape.updateForm(startPoint: startPoint, lastPoint: loc) //updates form of newly created shape while initial touch isn't released
            if self.activeTool == .freeDraw {
                startPoint = loc //Free Draw line creation: start point is the last touched point
            }
        }
        
        // leaving new shape on canvas when releasing first touch
        canvas.onTouchReleased { (event) in
            
            if self.activeTool == .none || self.selectionButton.isSelected { return }
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            if self.activeTool == .text { //special case for text behaviour and events
                self.setTextEvents(startPoint: startPoint)
                return //adds newly created text to shapes array and ignores subsequent events
            } else
            if let protractor = self.newShape as? Protractor { //special case for protractor behaviour and events
                self.setProtractorEvents(protractor: protractor)
                return //ignores subsequent events
            } else
            if let _ = self.newShape as? FreeDrawing {
                self.shapeTransformations[self.newShape.hash] = (startPoint.x,startPoint.y, 1, 0)
                return //ignores subsequent events
            } else if let line = self.newShape as? CustomLine {
                self.shapesGroup.contents.removeLast()
                self.newShape.updateForm(startPoint: Point(0, 0), lastPoint: Point(loc.x - startPoint.x, loc.y - startPoint.y))
                self.newShape.activateCircleAction()
                self.newShape.place = Transform.move(dx: startPoint.x, dy: startPoint.y).scale(sx: 1, sy: 1)
                self.shapeTransformations[self.newShape.hash] = (startPoint.x,startPoint.y, 1, 0)
                line.startPoint = startPoint
                line.lastPoint = loc
                self.shapesGroup.contents.append(line)
                self.setLineEvents(line: line)
                return
            } else { //general shape creation and events
                self.shapesGroup.contents.removeLast()
                self.newShape.updateForm(startPoint: Point(0, 0), lastPoint: Point(loc.x - startPoint.x, loc.y - startPoint.y))
                self.newShape.activateCircleAction()
                self.newShape.place = Transform.move(dx: startPoint.x, dy: startPoint.y).scale(sx: 1, sy: 1)
                self.shapeTransformations[self.newShape.hash] = (startPoint.x,startPoint.y, 1, 0)
            }
            
            // moving existing shape
            self.newShape.onPan { event in
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
                
                guard let node = event.node else { print("problem on panel pinch")
                    return
                }
                
                let transform = self.shapeTransformations[node.hash]
                self.shapeTransformations.updateValue((transform!.dx, transform!.dy, transform!.scale * event.scale, transform!.angle), forKey: node.hash)
                self.updatePlace(node: node)
                
                let newStroke = Stroke(fill: self.stroke.fill, width: self.stroke.width/(transform!.scale * event.scale))
                if let shape = node as? CustomShape {
                    shape.updateStroke(stroke: newStroke)
                }
            }
            
            self.newShape.onRotate { event in
                
                guard let node = event.node else { print("problem on panel rotate")
                    return
                }
                
                let transform = self.shapeTransformations[node.hash]
                self.shapeTransformations.updateValue((transform!.dx, transform!.dy, transform!.scale, transform!.angle + event.angle), forKey: node.hash)
                self.updatePlace(node: node)
            }
            
            self.shapesGroup.contents.append(self.newShape)
            self.canvasActive = false
        }
        
        group = Group(contents: [shapesGroup, canvas])
        macawView.node = group
    }
    
    func setLineEvents(line: CustomLine) {
        var startPoint = Point()
        var lastPoint = Point(x: 0, y: 0)
        var tempLine: CustomLine!
        
        line.circle2.onTouchPressed { (event) in
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            let transform = self.shapeTransformations[line.hash]
            
            let center = line.getCenter()
            
            lastPoint = Point(x: line.lastPoint.x - line.startPoint.x, y: line.lastPoint.y - line.startPoint.y)
            
            let lastPointAux = Shape(form: Point(x: 0, y: 0))

            lastPointAux.place = Transform.move(dx: transform!.dx + center!.x, dy:  transform!.dy + center!.y).scale(sx: transform!.scale, sy: transform!.scale).rotate(angle: transform!.angle).move(dx: -center!.x, dy: -center!.y).move(dx: lastPoint.x, dy: lastPoint.y)

            lastPoint = Point(x: lastPointAux.place.dx, y: lastPointAux.place.dy)
            
            tempLine = CustomLine(startPoint: loc, lastPoint: lastPoint, stroke: self.stroke)
            
            let index = self.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == line.hash
            })
            
            self.shapesGroup.contents[index!] = tempLine
        
        }
        
        line.circle.onTouchPressed { (event) in
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            let transform = self.shapeTransformations[line.hash]
            
            let pointAux = Shape(form: Point(x: 0, y: 0))
            
            let center = line.getCenter()
            
            pointAux.place = Transform.move(dx: transform!.dx + center!.x, dy: transform!.dy + center!.y).scale(sx: transform!.scale, sy: transform!.scale).rotate(angle: transform!.angle).move(dx: -center!.x, dy: -center!.y)
            
            startPoint = Point(x: pointAux.place.dx, y: pointAux.place.dy)
        
            tempLine = CustomLine(startPoint: startPoint, lastPoint: loc, stroke: self.stroke)
            
            let index = self.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == line.hash
            })
            
            self.shapesGroup.contents[index!] = tempLine
            
        }
        
        line.circle2.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene)  else {
                return
            }
            tempLine.updateForm(startPoint: loc, lastPoint: tempLine.lastPoint)
        }
        
        line.circle.onTouchMoved({ (event) in
            guard let loc = event.points.first?.location(in: .scene)  else {
                return
            }
            tempLine.updateForm(startPoint: tempLine.startPoint, lastPoint: loc)
        })
        
        line.circle2.onTouchReleased { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            let x = tempLine.lastPoint.x - loc.x
            let y = tempLine.lastPoint.y - loc.y
            
            let newLine = CustomLine(startPoint: Point(0, 0), lastPoint: Point(x: x, y: y), stroke: self.stroke)
            
            newLine.activateCircleAction()
            newLine.place = Transform.move(dx: loc.x, dy: loc.y).scale(sx: 1, sy: 1)
            
            newLine.startPoint = loc
            newLine.lastPoint = tempLine.lastPoint
            
            self.shapeTransformations[newLine.hash] = (loc.x, loc.y, 1, 0)
            
            let index = self.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == tempLine.hash
            })
            
            self.shapesGroup.contents[index!] = newLine
            
            self.setLineEvents(line: newLine)
        }
        
        line.circle.onTouchReleased { (event) in
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            let newLine = CustomLine(startPoint: Point(0, 0), lastPoint: Point(loc.x - startPoint.x, loc.y - startPoint.y), stroke: self.stroke)
            //newLine.updateForm(startPoint: Point(0, 0), lastPoint: Point(loc.x - startPoint.x, loc.y - startPoint.y))
            newLine.activateCircleAction()
            newLine.place = Transform.move(dx: startPoint.x, dy: startPoint.y).scale(sx: 1, sy: 1)
            
            newLine.startPoint = startPoint
            newLine.lastPoint = loc
            
            self.shapeTransformations[newLine.hash] = (startPoint.x,startPoint.y, 1, 0)
            
            let index = self.shapesGroup.contents.firstIndex(where: { (node) -> Bool in
                node.hash == tempLine.hash
            })
            
            self.shapesGroup.contents[index!] = newLine
            
            self.setLineEvents(line: newLine)
        }
        
        line.backgroundLine.onPan { (event) in
            guard let _ = event.node else { print("problem on line pan")
                return
            }
            let transform = self.shapeTransformations[line.hash]
            self.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: line.hash)
            self.updatePlace(node: line)
        }
        
        line.backgroundLine.onRotate { (event) in
            guard let _ = event.node else { print("problem on line rotate")
                return
            }
            
            let transform = self.shapeTransformations[line.hash]
            self.shapeTransformations.updateValue((transform!.dx, transform!.dy, transform!.scale, transform!.angle + event.angle), forKey: line.hash)
            self.updatePlace(node: line)
        }
        
        line.backgroundLine.onPinch { (event) in
            guard let _ = event.node else { print("problem on line pinch")
                return
            }
            
            let transform = self.shapeTransformations[line.hash]
            self.shapeTransformations.updateValue((transform!.dx, transform!.dy, transform!.scale * event.scale, transform!.angle), forKey: line.hash)
            self.updatePlace(node: line)
            
            let newStroke = Stroke(fill: self.stroke.fill, width: self.stroke.width/(transform!.scale * event.scale))
            let newCircleStroke = Stroke(fill: Color.clear, width: self.stroke.width/(transform!.scale * event.scale))
            
            line.updateStroke(stroke: newStroke)
            line.updateCircleStroke(stroke: newCircleStroke)
            line.updateSize(scale: transform!.scale * event.scale)
        }
    }
    
    func setTextEvents(startPoint: Point) {
        let customText = CustomText(text: "", startPoint: startPoint, color: self.textColor)
        self.customTexts.append(customText) //stores all created texts
        self.inputTextView.becomeFirstResponder() //always displays keyboard after creating text
        self.shapeTransformations[customText.hash] = (0,0, 1, 0)
        
        customText.onTap(f: { (event) in
            
            if self.isKeyboardShowing && !customText.isActive {
                self.inputTextView.resignFirstResponder()
                return
            }
            customText.isActive = !customText.isActive
            if customText.isActive {
                self.customTexts.removeAll(where: { (text) -> Bool in
                    text == customText
                })
                
                for text in self.customTexts {
                    text.isActive = false //deselects all texts except current one
                }
                
                self.customTexts.append(customText)
                self.inputTextView.becomeFirstResponder()
                
            } else {
                self.inputTextView.resignFirstResponder()
            }
        })
        
        customText.onPan { event in
            //self.scrollview.isScrollEnabled = false
            let transform = self.shapeTransformations[customText.hash]
            self.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: customText.hash)
            self.updatePlace(node: customText)
        }
        
        self.shapesGroup.contents.append(customText)
    }
    
    func setProtractorEvents(protractor: Protractor) {
        protractor.circle0.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene)  else {
                return
            }
            protractor.moveCircle(circle: .zero, toPoint: loc)
        }
        protractor.circle1.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene)  else {
                return
            }
            protractor.moveCircle(circle: .one, toPoint: loc)
        }
        protractor.circle2.onTouchMoved { (event) in
            guard let loc = event.points.first?.location(in: .scene)  else {
                return
            }
            protractor.moveCircle(circle: .two, toPoint: loc)
        }
    }
    
    func updatePlace(node: Node) {
        
        let shape = node as! CustomShape
        
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
        if lastSelectedButton != freeButton {
            if lastSelectedButton != nil {
                lastSelectedButton.isSelected = false
            }
            freeButton.isSelected = true
            lastSelectedButton = freeButton
        }
    }
    
    @IBAction func textTool(_ sender: UIButton) {
        activeTool = .text
        if lastSelectedButton != textButton {
            if lastSelectedButton != nil {
                lastSelectedButton.isSelected = false
            }
            textButton.isSelected = true
            lastSelectedButton = textButton
        }
    }
    
    @IBAction func activeLineTool(_ sender: UIButton) {
        activeTool = .line
        if lastSelectedButton != lineButton {
            if lastSelectedButton != nil {
                lastSelectedButton.isSelected = false
            }
            lineButton.isSelected = true
            lastSelectedButton = lineButton
        }
    }
    
    @IBAction func activeRectTool(_ sender: UIButton) {
        activeTool = .rect
        if lastSelectedButton != rectButton {
            if lastSelectedButton != nil {
                lastSelectedButton.isSelected = false
            }
            rectButton.isSelected = true
            lastSelectedButton = rectButton
        }
    }
    
    @IBAction func activeCircleTool(_ sender: Any) {
        activeTool = .ellipse
        if lastSelectedButton != circleButton {
            if lastSelectedButton != nil {
                lastSelectedButton.isSelected = false
            }
            circleButton.isSelected = true
            lastSelectedButton = circleButton
        }
    }
    
    @IBAction func activeShapeTool(_ sender: Any) {
        activeTool = .protractor
        if lastSelectedButton != protractorButton {
            if lastSelectedButton != nil {
                lastSelectedButton.isSelected = false
            }
            protractorButton.isSelected = true
            lastSelectedButton = protractorButton
        }
    }
    
    @IBAction func activeArrowTool(_ sender: Any) {
        activeTool = .arrow
        if lastSelectedButton != arrowButton {
            if lastSelectedButton != nil {
                lastSelectedButton.isSelected = false
            }
            arrowButton.isSelected = true
            lastSelectedButton = arrowButton
        }
    }
    
    @IBAction func activeAsteriskTool(_ sender: Any) {
        activeTool = .asterisk
        if lastSelectedButton != asteriskButton {
            if lastSelectedButton != nil {
                lastSelectedButton.isSelected = false
            }
            asteriskButton.isSelected = true
            lastSelectedButton = asteriskButton
        }
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
            if let text = undoneNode as? CustomText {
                text.deleteShape()
            }
            redoShapes.append(undoneNode)
        }
    }
    
    @IBAction func redoTool(_ sender: Any) {
        if let redoneNode = redoShapes.popLast() {
            if let freeDrawing = redoneNode as? FreeDrawing {
                freeDrawing.redoShape()
            }
            if let text = redoneNode as? CustomText {
                text.redoShape()
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

extension ViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let customText = customTexts.last
        textView.text = customText?.textNode.text
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let customText = customTexts.last
        customText?.setText(text: textView.text ?? "")
    }
}
