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
    case arc
    case multiline
    case delete
    case selection
    case none
}

protocol MacawViewDelegate: class {
    func activateScrollView(enable: Bool)
    func setLastActiveShape(newShape: CustomShape)
    var shapesGroup: Group { get set }
    var activeTool: Annotation.Types { get set }
    var textColor: Color { get }
    var customTexts: [CustomText] { get set }
    var isKeyboardShowing: Bool { get }
    var lastActiveShape: CustomShape? { get set }
    var macawTextActive: Bool { get set }
    var macawView: MacawView { get set }
}

class ViewController: UIViewController, MacawViewDelegate {
    
    var colorSelectorPopup: ColorSelectorPopup!
    var selectorBackground: UIView!
    
    var previousMacawHeight: CGFloat! //stores previous Macaw view height to be used on view redimensions
    var previousMacawWidth: CGFloat! //stores previous Macaw view width to be used on view redimensions
    
    var newMacawHeight: CGFloat? //stores new Macaw view height to be used on view redimensions
    var newMacawWidth: CGFloat? //stores new Macaw view width to be used on view redimensions
    
    var macawTextActive: Bool = false {
        didSet {
            if macawTextActive {
                inputTextView.becomeFirstResponder()
            } else {
                inputTextView.resignFirstResponder()
            }
        }
    }
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextView: UITextView = {
        let textView = UITextView()
        return textView
    }()
    
    let textColor = Color.red
    var textSize: Double = 12.0
    
    var group: Group! //Macaw group to store all shapes
    var lastActiveShape: CustomShape?
    var cropRect: Shape?
    var customTexts: [CustomText] = []
    
    var isKeyboardShowing: Bool = false
    
    var drawingActive: Bool = true { //puts canvas in front of shapes to draw on it, or shapes over canvas to be selected
        didSet {
            if oldValue != drawingActive {
                let first = group.contents.remove(at: 0)
                group.contents.append(first)
            }
        }
    }
    
    var isNewShape: Bool = true //global variable used for nerve and multiline shapes to determina if a new line or a new shape should be created
    
    var activeTool: Annotation.Types = .none {
        willSet {
            if newValue == .none {
                isNewShape = true
                freeButton.isSelected = false
                textButton.isSelected = false
                lineButton.isSelected = false
                rectButton.isSelected = false
                circleButton.isSelected = false
                protractorButton.isSelected = false
                arcButton.isSelected = false
                arrowButton.isSelected = false
                asteriskButton.isSelected = false
                multilineButton.isSelected = false
                selectionButton.isSelected = false
                handButton.isSelected = false
                deleteButton.isSelected = false
            }
        }
    }
    
    var bottomConstraint: NSLayoutConstraint?
    
    var canvas: Shape! //rectangle shape where new shapes are drawn
    var macawView = MacawView()
    var shapesGroup = Group() //macaw group node where shapes are stored

    var lastActiveView: UIView?
    var selectionView: UIView!
        
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var freeButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var lineButton: UIButton!
    @IBOutlet weak var rectButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var protractorButton: UIButton!
    @IBOutlet weak var arcButton: UIButton!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var asteriskButton: UIButton!
    @IBOutlet weak var multilineButton: UIButton!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var handButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
        
    var lastSelectedButton: UIButton!
    
    let stroke = Stroke(fill: Color.red, width: 4.0)
    
    var redoShapes: [Node] = []
    
    var newShape: CustomShape!
    
    let image = #imageLiteral(resourceName: "Medical_X-Ray_imaging_AAR02_nevit")
    
    var backgroundView = UIView()
    
    var imageView = UIImageView()
       
    var newAnnotationId: Int = 0
    
    @IBAction func selectionTool(_ sender: UIButton) {
        setSelectionTool(activate: !sender.isSelected)
    }
    
    func setSelectionTool(activate: Bool) {
        activeTool = .none
        if !activate {
            selectionButton.isSelected = false
            drawingActive = true
        } else {
            selectionButton.isSelected = true
            drawingActive = false
        }
        isNewShape = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupBackgroundView()
        setupMacawView()
        createCanvas()
        configInputContainer()
        setupColorSelectorView()
    }
    
    func setupScrollView() {
        activateScrollView(enable: false)
        imageScrollView.delegate = self
        imageScrollView.bounces = false
        imageScrollView.bouncesZoom = false
        imageScrollView.minimumZoomScale = 1.0
    }
    
    func setupBackgroundView() {
        imageScrollView.addSubview(backgroundView)
        
        backgroundView.snp.makeConstraints { (make) in
            make.centerX.equalTo(imageScrollView.snp.centerX)
            make.centerY.equalTo(imageScrollView.snp.centerY)
            make.width.equalTo(imageScrollView.snp.width)
            make.height.equalTo(imageScrollView.snp.height)
        }
        
        imageView.backgroundColor = .darkGray
        
        imageScrollView.contentSize = CGSize(width: backgroundView.frame.width, height: backgroundView.frame.height)

        backgroundView.addSubview(imageView)
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(backgroundView.snp.centerX)
            make.centerY.equalTo(backgroundView.snp.centerY)
            make.width.equalTo(backgroundView.snp.width)
            make.height.equalTo(backgroundView.snp.height)
        }
    }
    
    func setupMacawView() {
        macawView.backgroundColor = .clear
        backgroundView.addSubview(macawView)
        
        macawView.snp.makeConstraints { (make) in
            make.centerX.equalTo(imageView.snp.centerX)
            make.centerY.equalTo(imageView.snp.centerY)
            make.width.equalTo(imageView.snp.width)
            make.height.equalTo(imageView.snp.height)
        }
        
        canvas = Shape(form: Rect(x: 0, y: 0, w: Double(UIScreen.main.bounds.width), h: Double(UIScreen.main.bounds.height)), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 1.0))
        
        macawView.node = Group(contents: [shapesGroup, canvas])
    }
    
    func setupColorSelectorView() {
        
        colorButton.setColoredButtonText()
        
        colorSelectorPopup = ColorSelectorPopup(frame: .zero)
        selectorBackground = UIView()
        selectorBackground.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(selectorBackground)
        selectorBackground.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        selectorBackground.addSubview(colorSelectorPopup)
        colorSelectorPopup.snp.makeConstraints { (make) in
            make.width.equalTo(300)
            make.height.equalTo(330)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        selectorBackground.isHidden = true
        colorSelectorPopup.delegate = self
        
        self.view.bringSubviewToFront(selectorBackground)
    }
    
//    func updateMacawViewConstraints() { //updates macaw view constraints after image constraints are changed; macawView covers only visible image, not black bars
//
//        newMacawHeight = examImage.calculateRectOfImageInImageView().height
//        newMacawWidth = examImage.calculateRectOfImageInImageView().width
//
//        macawView.snp.remakeConstraints { (make) in
//            make.centerX.equalTo(examImage.snp.centerX)
//            make.centerY.equalTo(examImage.snp.centerY)
//            make.height.equalTo(newMacawHeight!)
//            make.width.equalTo(newMacawWidth!)
//        }
//    }
    
    func configInputContainer() { //custom message container setup
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
        inputTextView.leadingAnchor.constraint(equalTo: messageInputContainerView.leadingAnchor, constant: 0).isActive = true
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
            
            isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification //storing keyboard state for future reference for text events
            
            if isKeyboardShowing {
                bottomConstraint?.constant = -keyboardFrame.height
                if macawTextActive {
                    self.messageInputContainerView.isHidden = false
                }
            } else {
                bottomConstraint?.constant = 0
                self.messageInputContainerView.isHidden = true
                macawTextActive = false
            }
            
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
            }
        }
    }

    func createCanvas() {
        
        var newShape: CustomShape!
        var timer: ParkBenchTimer!
        var startPoint = Point()
        var isLastPoint = false
        
        // creating new shape during first touch on canvas
        canvas.onTouchPressed { [weak self] event in
            
            if self!.selectionButton.isSelected {
                if self!.lastActiveShape != nil {
                    self?.lastActiveShape?.isActive = false //deselects last shape
                    self?.lastActiveShape = nil
                }
                return
            }
            
            let stroke = Stroke(fill: Color(val: self!.colorSelectorPopup.colorValue), width: 5.0)
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            startPoint = loc //stores initial touch point of new shape to be referenced on subsequent events
            
            if self!.isNewShape {
                self?.newAnnotationId += 1
            }
            
            //stores new shape to be referenced on subsequent events
            switch self!.activeTool {
            case .none:
                return
            case .freeDrawing:
                newShape = FreeDrawing(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .freeDrawing, annotationId: self!.newAnnotationId)
                if let shape = self!.lastActiveShape {
                    if shape.isActive {
                        shape.isActive = false
                    }
                }
            case .text:
                newShape = CustomText(text: "", startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .text, annotationId: self!.newAnnotationId, comment: "")
            case .line:
                newShape = CustomLine(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .line, annotationId: self!.newAnnotationId, comment: "")
            case .ellipse:
                newShape = CustomEllipse(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .ellipse, annotationId: self!.newAnnotationId, comment: "")
            case .rect:
                newShape = CustomRect(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .rect, annotationId: self!.newAnnotationId, comment: "")
            case .arrow:
                newShape = Arrow(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .arrow, annotationId: self!.newAnnotationId, comment: "")
            case .protractor:
                newShape = Protractor(p0: startPoint, p1: startPoint, p2: startPoint, delegate: self!, stroke: stroke, type: .protractor, annotationId: self!.newAnnotationId, comment: "")
            case .asterisk:
                newShape = Asterisk(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .asterisk, annotationId: self!.newAnnotationId, comment: "")
            case .arc:
                newShape = CustomArc(p0: startPoint, p1: startPoint, p2: startPoint, delegate: self!, stroke: stroke, type: .arc, annotationId: self!.newAnnotationId, comment: "")
            case .multiline:
                if self!.isNewShape {
                    newShape = Multiline(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .multiline, annotationId: self!.newAnnotationId)
                    timer = ParkBenchTimer()
                    isLastPoint = false
                } else {
                    if let multiline = newShape as? Multiline {
                        let time = timer.stop()
                        if time < 0.5 {
                            self?.isNewShape = true
                            isLastPoint = true
                        } else {
                            multiline.newPoint(point: startPoint)
                            timer = ParkBenchTimer()
                        }
                    }
                    return
                }
            }
            
            self?.setLastActiveShape(newShape: newShape)
            self?.shapesGroup.contents.append(newShape)
            
        }
        
        // resizing new shape when moving first touch
        canvas.onTouchMoved { [weak self] (event) in
            if self!.activeTool == .none || self!.selectionButton.isSelected { return }
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            newShape.updateForm(startPoint: startPoint, lastPoint: loc) //updates form of newly created shape while initial touch isn't released
            if self!.activeTool == .freeDrawing {
                startPoint = loc //Free Draw line creation: start point is the last touched point
            }
        }
        
        // leaving new shape on canvas when releasing first touch
        canvas.onTouchReleased { [weak self] (event) in
            
            if self!.selectionButton.isSelected { return }
            
            switch self!.activeTool {
            case .none:
                return
            case .text:
                if self!.isKeyboardShowing {
                    self?.inputTextView.resignFirstResponder()
                    return
                }
                let customText = newShape as! CustomText
                customText.delegate = self
                self?.customTexts.append(customText) //stores all
                customText.setTransformEvents()
                self?.macawTextActive = true
                self?.inputTextView.becomeFirstResponder() //always displays keyboard after creating text
                self?.setSelectionTool(activate: true)
            return //adds newly created text to shapes array and ignores subsequent events
            case .multiline:
                if let multiline = newShape as? Multiline {
                    if self!.isNewShape {
                        if isLastPoint {
                            self?.isNewShape = true
                            if multiline.points.count == 1 {
                                self?.shapesGroup.contents.removeAll(where: { (node) -> Bool in
                                    node.hash == multiline.hash
                                })
                            }
                            self?.setSelectionTool(activate: true)
                            return
                        } else {
                            multiline.delegate = self
                            multiline.setTransformEvents()
                            self?.setTapEvent(node: newShape)
                            self?.isNewShape = false
                        }
                    } else {
                        return
                    }
                }
            default:
                if let freeDrawing = newShape as? FreeDrawing {
                    self?.selectShape(node: freeDrawing)
                }
                newShape.delegate = self
                newShape.setTransformEvents()
                self?.setTapEvent(node: newShape)
                self?.setSelectionTool(activate: true)
                return
            }
        }
        
        group = Group(contents: [shapesGroup, canvas])
        macawView.node = group
        newShape = nil
    }
    
    func setTapEvent(node: CustomShape) {
        node.onTap(f: { [weak self] (event) in
            
            if self!.activeTool == .none && self!.deleteButton.isSelected {
                self!.deleteShape(node: node)
            }
            
            if self!.activeTool == .none && !self!.selectionButton.isSelected { return }
            guard let node = event.node as? CustomShape else { print("problem on panel tap")
                return
            }
            self?.selectShape(node: node)
        })
    }
    
    func deleteShape(node: CustomShape) {
        self.shapesGroup.contents.removeAll(where: { (shape) -> Bool in
            shape.hash == node.hash
        })
    }

    func selectShape(node: CustomShape) {
        node.isActive = !node.isActive
        if node.isActive {
            self.shapesGroup.contents.removeAll(where: { (shape) -> Bool in
                shape.hash == node.hash
            })
            self.shapesGroup.contents.append(node) //putting active shape at top of created shapes
        }
        self.setLastActiveShape(newShape: node)
    }
    
    func activateScrollView(enable: Bool) {
        imageScrollView.isScrollEnabled = enable
        imageScrollView.pinchGestureRecognizer?.isEnabled = enable
    }
    
    func setLastActiveShape(newShape: CustomShape) { //deselects last selected shape and updates it with new shape
        if newShape.isActive {
            if self.lastActiveShape != nil {
                if self.lastActiveShape!.isHidden {
                    self.lastActiveShape!.isActive = false
                    self.lastActiveShape!.isHidden = true
                } else {
                    self.lastActiveShape!.isActive = false
                }
            }
            self.lastActiveShape = newShape
        } else {
            self.lastActiveShape = nil
        }
    }
    
    @IBAction func freeDrawingTool(_ sender: UIButton) {
        toolSelected()
        activeTool = .freeDrawing
        freeButton.isSelected = true
    }
    
    @IBAction func textTool(_ sender: UIButton) {
        toolSelected()
        activeTool = .text
        textButton.isSelected = true
    }
    
    @IBAction func activeLineTool(_ sender: UIButton) {
        toolSelected()
        activeTool = .line
        lineButton.isSelected = true

    }
    
    @IBAction func activeRectTool(_ sender: UIButton) {
        toolSelected()
        activeTool = .rect
        rectButton.isSelected = true
    }
    
    @IBAction func activeCircleTool(_ sender: Any) {
        toolSelected()
        activeTool = .ellipse
        circleButton.isSelected = true
    }
    
    @IBAction func activeShapeTool(_ sender: Any) {
        toolSelected()
        activeTool = .protractor
        protractorButton.isSelected = true
    }
    
    @IBAction func activeArrowTool(_ sender: Any) {
        toolSelected()
        activeTool = .arrow
        arrowButton.isSelected = true
    }
    
    @IBAction func activeAsteriskTool(_ sender: Any) {
        toolSelected()
        activeTool = .asterisk
        asteriskButton.isSelected = true
    }
    
    @IBAction func activateArcTool(_ sender: UIButton) {
        toolSelected()
        activeTool = .arc
        arcButton.isSelected = true
    }
    
    @IBAction func activateMultilineTool(_ sender: UIButton) {
        toolSelected()
        activeTool = .multiline
        multilineButton.isSelected = true
    }
    
    @IBAction func activateSelectionTool(_ sender: Any) {
        setSelectionTool(activate: !selectionButton.isSelected)
    }

    @IBAction func deleteTool(_ sender: UIButton) {
        if let shape = lastActiveShape {
            if shape.isActive {
                deleteShape(node: shape)
                lastActiveShape = nil
            }
        }
    }
    
    @IBAction func colorTool(_ sender: UIButton) {
        selectorBackground.isHidden = false
        if let shape = lastActiveShape {
            if shape.isActive {
                colorSelectorPopup.annotationId = shape.annotationId
            }
        } else {
            colorSelectorPopup.annotationId = nil
        }
    }

    func toolSelected() {
        activateScrollView(enable: false)
        activeTool = .none
        drawingActive = true
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return backgroundView
    }
}

extension ViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == inputTextView {
            let customText = customTexts.last
            textView.text = customText?.textNode.text
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == inputTextView { //logic for automatic line breaking in text
            if let customText = customTexts.last {
                customText.setText(text: textView.text ?? "")
                if customText.textNode.bounds.h > customText.rectLimit.form.bounds().h {
                    customText.updateBoundsHeight()
                }
                if customText.textNode.bounds.w > customText.rectLimit.form.bounds().w {
                    var textString = customText.textNode.text
                    let textStringWithoutBreak = textString
                    textString = breakLine(text: textString)
                    customText.setText(text: textString)
                    if customText.textNode.bounds.w > customText.rectLimit.form.bounds().w  {
                        customText.updateBoundsWidth()
                        customText.setText(text: textStringWithoutBreak)
                    }
                    if customText.textNode.bounds.h > customText.rectLimit.form.bounds().h {
                        customText.updateBoundsHeight()
                    }
                }
                textView.text = customText.textNode.text
            }
        }
    }
    
    func breakLine(text: String) -> String {
        var text = text
        for i in stride(from: text.count-1, to: 0, by: -1) {
            if text[i] == " " {
                let offset = i == text.count-1 ? i : i+1
                text.insert("\n", at: text.index(text.startIndex, offsetBy: offset))
                break
            }
        }
        return text
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == inputTextView {
            if textView.text == "" {
                if let customText = customTexts.last {
                    deleteShape(node: customText)
                }
            }
        }
    }
}

extension ViewController: ColorSelectorPopupDelegate {

    func dismiss() {
        selectorBackground.isHidden = true
    }
    
    func colorSelected(color: Color, annotationId: Int?) {
        if annotationId == nil {
            selectorBackground.isHidden = true
            return
        }
        if let shape = shapesGroup.contents.first(where: { (node) -> Bool in
            let shape = node as! CustomShape
            return shape.annotationId == annotationId
        }) as? CustomShape {
                let stroke = Stroke(fill: color, width: shape.stroke.width)
                shape.updateStroke(stroke: stroke, stroke2: nil)
                selectorBackground.isHidden = true
        }
    }
}
