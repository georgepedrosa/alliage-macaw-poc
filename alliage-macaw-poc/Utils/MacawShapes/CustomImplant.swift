////
////  CustomImplant.swift
////  Alliage
////
////  Created by George Pedrosa on 28/10/19.
////  Copyright © 2019 LDS. All rights reserved.
////
//
//import UIKit
//import Macaw
//
//class CustomImplant: Group, CustomShape {
//    
//    let radiansPerDegree = App.Constants.radiansPerDegree
//    let degreesPerRadian = App.Constants.degreesPerRadian
//    
//    var coordinateSystem: CoordinateSystem!
//    
//    weak var delegate: MacawViewDelegate?
//    
//    var id: Int!
//    var type: Annotation.Types!
//    var comment: String = ""
//    var annotationId: Int!
//    var idImplant: Int!
//    var pixelsPerMilimeter: Double!
//    var implantType: Implant!
//    var implantImage: UIImage!
//    
//    var rotateCircle: Shape!
//    var anchorLine: Shape!
//    var anchorHead: Shape!
//    
//    var activeContents: [Node]!
//    
//    var inactiveContents: [Node]!
//    
//    var center: CGPoint!
//    
//    var transform: CGAffineTransform?
//    
//    var stroke: Stroke!
//    
//    var p0: Point!
//    var p1: Point!
//    
//    var pCenter: Point!
//    
//    var backgroundRect: Shape!
//    var touchBackgroundRect: Shape!
//    
//    var rotatedAngle: Double = 0
//    
//    var isActive: Bool = true {
//        didSet {
//            isHidden = false
//        }
//    }
//    
//    var isHidden: Bool = false {
//        didSet {
//            if isHidden {
//                contents = []
//                pinoImageView.isHidden = true
//            } else {
//                contents = isActive ? activeContents : inactiveContents
//                pinoImageView.isHidden = false
//            }
//        }
//    }
//    
//    var pinoImageView: UIImageView = {
//        let image = UIImageView(image: UIImage(named: "implant"))
//        return image
//    }()
//    
////    deinit {
////        pinoImageView.removeFromSuperview()
////    }
//    
//    required init(startPoint: Point, lastPoint: Point, delegate: MacawViewDelegate?, type: Annotation.Types, id: Int? = nil, annotationId: Int?, comment: String, image: UIImage?, idImplant: Int, calibration: Double, rotation: Double, implantType: Implant, coordinateSystem: CoordinateSystem) {
//        super.init()
//        
//        self.type = type
//        self.id = id
//        if let id = annotationId {
//            self.annotationId = id
//        } else {
//            self.annotationId = self.hashValue
//        }
//        self.comment = comment
//        self.delegate = delegate
//        self.idImplant = idImplant
//        self.pixelsPerMilimeter = calibration
//        self.stroke = Stroke(fill: Color.white, width: 2.0, dashes: [5, 5])
//        self.rotatedAngle = rotation
//        self.implantType = implantType
//        self.implantImage = image
//        self.coordinateSystem = coordinateSystem
//        
//        let targetSize = CGSize(width: getProportionalWidth(), height: getProportionalHeight())
//        
//        if let img = image {
//            if let resizedImg = img.resize(to: targetSize, aspectFit: false) {
//                pinoImageView.image = resizedImg
//            }
//        }
//        backgroundRect = Shape(form: Rect(), fill: Color.clear, stroke: stroke)
//        touchBackgroundRect = Shape(form: Rect(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 1.0))
//        
//        self.delegate?.macawView.addSubview(pinoImageView)
//        
//        let x = startPoint.x - Double(pinoImageView.image!.size.width)/2
//        let y = startPoint.y - Double(pinoImageView.image!.size.height)/2
//        
//        p0 = Point(x,y)
//        
//        pCenter = startPoint
//        p1 = Point(x: p0.x + Double(pinoImageView.image!.size.width), y: p0.y + Double(pinoImageView.image!.size.height/2))
//        
//        rotateCircle = Shape(form: Circle(), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 2.0))
//        anchorLine = Shape(form: Line(), fill: Color.black, stroke: Stroke(fill: Color.black, width: 1.0))
//        anchorHead = Shape(form: Circle(), fill: Color.white, stroke: Stroke(fill: Color.black, width: 1.0))
//        
//        pinoImageView.frame = CGRect(x: p0.x, y: p0.y, width: Double(pinoImageView.image!.size.width), height: Double(pinoImageView.image!.size.height))
//        pinoImageView.contentMode = .center
//        self.center = self.pinoImageView.center
//        
//        activeContents = [backgroundRect, anchorLine, anchorHead, rotateCircle]
//        inactiveContents = [touchBackgroundRect]
//        
//        contents = activeContents
//        
////        updateFormFromPoints()
//        setRotatedAngle()
//    }
//    
//    func getProportionalWidth() -> Double {
//        let newWidth = (implantType.diametroImplante * coordinateSystem.frameWidth) / coordinateSystem.imageWidth
//        return (newWidth * pixelsPerMilimeter)
//    }
//    
//    func getProportionalHeight() -> Double {
//        let newHeight = (implantType.alturaImplante * coordinateSystem.frameHeight) / coordinateSystem.imageHeight
//        return (newHeight * pixelsPerMilimeter)
//    }
//    
//    func updateForm(startPoint: Point, lastPoint: Point) {
//    }
//    
//    func updateStroke(stroke: Stroke, stroke2: Stroke?) {
//    }
//    
//    func updateCalibration(pixelsPerMilimeter: Double) {
//        self.pixelsPerMilimeter = pixelsPerMilimeter
//        let targetSize = CGSize(width: getProportionalWidth(), height: getProportionalHeight())
//        resizeImplant(to: targetSize)
//    }
//    
//    func getCenter() -> Point? {
//        return backgroundRect.bounds?.center()
//    }
//    
//    func setTransformEvents() {
//        backgroundRect.onPan { [weak self] (event) in
//            guard let _ = event.node else { print("problem on backgroundRect pan")
//                return
//            }
//            if !(self?.isActive)! { return }
//            self?.delegate?.activateScrollView(enable: false)
//            self?.move(dx: event.dx, dy: event.dy)
//            self?.delegate?.activateScrollView(enable: true)
//        }
//
//        rotateCircle.onTouchMoved { [weak self] (event) in
//            guard let _ = event.node else { print("problem on rotateCircle moved")
//                return
//            }
//            guard let loc = event.points.first?.location(in: .scene) else { return }
//            self?.delegate?.activateScrollView(enable: false)
//            let theta1 = atan2(loc.y - self!.pCenter.y, loc.x - self!.pCenter.x)
//            var currentAngle: Double!
//            if theta1 < Double.pi {
//                currentAngle = theta1
//            } else {
//                currentAngle = (2*Double.pi) - (theta1)
//            }
//            let center = self!.pCenter//self?.pinoImageView.center
//            self?.transform = CGAffineTransform(translationX: CGFloat(-center!.x), y: CGFloat(-center!.y)).concatenating(CGAffineTransform(rotationAngle: CGFloat(currentAngle))).concatenating(CGAffineTransform(translationX: CGFloat(center!.x), y: CGFloat(center!.y)))
//            self?.rotatedAngle = currentAngle*(self?.degreesPerRadian)!
//            self?.pinoImageView.transform = (self?.transform!)!
//            let d = Double(self!.pinoImageView.image!.size.width)
//            self!.p1 = Point(x: self!.pCenter.x + d * cos(currentAngle), y: self!.pCenter.y + d * sin(currentAngle))
//            self!.updateFormFromPoints()
//            self?.delegate?.activateScrollView(enable: true)
//        }
//    }
//    
//    func updateFormFromPoints() {
//        backgroundRect.form = Rect(x: p0.x - Double(pinoImageView.image!.size.height)/2 + Double(pinoImageView.image!.size.width)/2, y: p0.y, w: Double(pinoImageView.image!.size.height), h: Double(pinoImageView.image!.size.height))
//        touchBackgroundRect.form = backgroundRect.form
//        pinoImageView.frame = CGRect(x: p0.x, y: p0.y, width: Double(pinoImageView.image!.size.width), height: Double(pinoImageView.image!.size.height))
//        rotateCircle.form = Circle(cx: p1.x, cy: p1.y, r: 20.0)
//        anchorHead.form = Circle(cx: p1.x, cy: p1.y, r: 4.0)
//        anchorLine.form = Line(x1: pCenter.x, y1: pCenter.y, x2: p1.x, y2: p1.y)
//    }
//    
//    func move(dx: Double, dy: Double) {
//        pCenter = Point(x: pCenter.x + dx, y: pCenter.y + dy)
//        p0 = Point(x: p0.x + dx, y: p0.y + dy)
//        p1 = Point(x: p1.x + dx, y: p1.y + dy)
//        updateFormFromPoints()
//    }
//    
//    func resizeImplant(to size: CGSize) {
//        if let resizedImg = self.implantImage.resize(to: size, aspectFit: false) {
//            pinoImageView.image = resizedImg
//            setRotatedAngle()
//        }
////        pCenter = getCenter()
//        let x = pCenter.x - Double(pinoImageView.image!.size.width)/2
//        let y = pCenter.y - Double(pinoImageView.image!.size.height)/2
//        p0 = Point(x,y)
//        let d = Double(pinoImageView.image!.size.width)
//        self.p1 = Point(x: pCenter.x + d * cos(rotatedAngle*radiansPerDegree), y: pCenter.y + d * sin(rotatedAngle*radiansPerDegree))
//        updateFormFromPoints()
//    }
//    
//    func setRotatedAngle() {
//        let center = pinoImageView.center
//        transform = CGAffineTransform(translationX: -center.x, y: -center.y).concatenating(CGAffineTransform(rotationAngle: CGFloat(rotatedAngle*radiansPerDegree))).concatenating(CGAffineTransform(translationX: center.x, y: center.y))
//        pinoImageView.transform = transform!
//        pinoImageView.frame = CGRect(x: p0.x, y: p0.y, width: Double(pinoImageView.image!.size.width), height: Double(pinoImageView.image!.size.height))
//        let d = Double(pinoImageView.image!.size.width)
//        self.p1 = Point(x: pCenter.x + d * cos(rotatedAngle*radiansPerDegree), y: pCenter.y + d * sin(rotatedAngle*radiansPerDegree))
//        updateFormFromPoints()
//    }
//}
